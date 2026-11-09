require "minitest/autorun"
require_relative "../lib/player"
require_relative "../lib/doubly_linked_list"
require_relative "../lib/turn"
require_relative "../lib/capture"

# Tests for Braedan Chappel's issues #1, #5, #6, #10 and #11.
class BraedanFoundationTest < Minitest::Test
  # These doubles exercise the received interfaces while teammates build them.
  TestPit = Struct.new(:row, :column, :seeds) do
    def getColumn
      column
    end

    def getSeeds
      seeds
    end

    def removeAllSeeds
      removed = seeds
      self.seeds = 0
      removed
    end
  end

  TestSide = Struct.new(:inner_row) do
    def isInner(pit)
      pit.row == inner_row
    end
  end

  TestBoard = Struct.new(:sides, :opposing) do
    def getSide(player)
      sides.fetch(player.getId)
    end

    def getOpposingPits(pit)
      opposing.fetch(pit.object_id)
    end
  end

  def setup
    @player = Player.new(1, "Alice")
  end

  def test_player_retains_each_players_identity
    [[1, "Alice"], [2, "Bob"]].each do |id, name|
      player = Player.new(id, name)
      assert_equal id, player.getId
      assert_equal name, player.getName
    end
  end

  def test_player_preserves_name_without_normalizing_it
    assert_equal " Alice Smith ", Player.new(1, " Alice Smith ").getName
  end

  def test_new_node_is_unlinked_and_keeps_the_same_pit
    pit = TestPit.new(2, 0, 3)
    node = Node.new(pit)
    assert_same pit, node.getPit
    assert_nil node.getNext
    assert_nil node.getPrev
    assert_same pit, node.next(0)
    assert_same pit, node.prev(0)
  end

  def test_node_link_setters_keep_the_supplied_nodes
    node, following, previous = Array.new(3) { Node.new(Object.new) }
    node.setNext(following)
    node.setPrev(previous)
    assert_same following, node.getNext
    assert_same previous, node.getPrev
  end

  def test_negative_node_steps_raise
    node = Node.new(Object.new)
    assert_raises(ArgumentError) { node.next(-1) }
    assert_raises(ArgumentError) { node.prev(-1) }
  end

  def test_empty_list_search_returns_nil
    assert_nil DoublyLinkedList.new([]).find(Object.new)
  end

  def test_first_append_creates_a_self_linked_ring
    list = DoublyLinkedList.new([])
    pit = Object.new
    list.append(pit)
    node = list.find(pit)
    assert_same node, node.getNext
    assert_same node, node.getPrev
    assert_same pit, node.next(20)
    assert_same pit, node.prev(20)
  end

  def test_ring_preserves_order_and_both_links_for_all_sixteen_pits
    pits = Array.new(16) { |i| TestPit.new(2 + i / 8, i % 8, 0) }
    list = DoublyLinkedList.new(pits)
    pits.each_with_index do |pit, i|
      node = list.find(pit)
      assert_same pit, node.getPit
      assert_same list.find(pits[(i + 1) % 16]), node.getNext
      assert_same list.find(pits[(i - 1) % 16]), node.getPrev
      assert_same node, node.getNext.getPrev
      assert_same node, node.getPrev.getNext
    end
    assert_same pits[1], list.find(pits[0]).next(33)
    assert_same pits[15], list.find(pits[0]).prev(33)
  end

  def test_append_to_existing_ring_preserves_head_order
    pits = Array.new(3) { Object.new }
    list = DoublyLinkedList.new(pits.take(2))
    head = list.find(pits[0])
    list.append(pits[2])
    assert_same head, list.find(pits[0])
    assert_same pits[2], head.prev(1)
    assert_same pits[2], head.next(2)
    assert_same head, list.find(pits[2]).getNext
  end

  def test_find_uses_identity_instead_of_equal_values
    original = TestPit.new(2, 0, 3)
    equal_value = TestPit.new(2, 0, 3)
    assert_equal original, equal_value
    list = DoublyLinkedList.new([original])
    assert_nil list.find(equal_value)
    assert_same original, list.find(original).getPit
  end

  def test_find_returns_first_occurrence_and_terminates_for_missing_pit
    pit = Object.new
    list = DoublyLinkedList.new([pit, Object.new, pit])
    assert_same list.find(pit), list.find(pit).getPrev.getNext
    assert_same pit, list.find(pit).getPrev.getPit
    assert_nil list.find(Object.new)
  end

  def test_large_node_steps_wrap_without_using_the_call_stack
    pit = Object.new
    node = DoublyLinkedList.new([pit]).find(pit)
    assert_same pit, node.next(10_000)
    assert_same pit, node.prev(10_000)
  end

  def test_new_turn_retains_player_and_has_no_timeout_or_end_capture
    turn = Turn.new(@player)
    assert_same @player, turn.getPlayer
    refute turn.isTimedOut
    refute turn.capturedBothEnds
    assert_equal 180, Turn::TIME_LIMIT
  end

  def test_timeout_is_strictly_after_180_seconds
    turn = Turn.new(@player)
    started = Time.at(1000)
    Time.stub(:now, started) { turn.startSowing }
    [0, 179, 180].each do |elapsed|
      Time.stub(:now, started + elapsed) { refute turn.isTimedOut }
    end
    Time.stub(:now, started + 180.001) { assert turn.isTimedOut }
  end

  def test_relay_or_reverse_start_does_not_reset_clock
    turn = Turn.new(@player)
    Time.stub(:now, Time.at(1000)) { turn.startSowing }
    Time.stub(:now, Time.at(1170)) { turn.startSowing }
    Time.stub(:now, Time.at(1181)) { assert turn.isTimedOut }
  end

  def test_both_end_columns_are_required_in_either_order
    [[0, 7], [7, 0]].each do |columns|
      turn = Turn.new(@player)
      turn.recordCapture(columns[0])
      refute turn.capturedBothEnds
      turn.recordCapture(columns[1])
      assert turn.capturedBothEnds
    end
  end

  def test_repeated_and_middle_captures_do_not_count_as_both_ends
    turn = Turn.new(@player)
    [0, 0, 1, 2, 3, 4, 5, 6].each { |column| turn.recordCapture(column) }
    refute turn.capturedBothEnds
  end

  def test_new_turn_does_not_inherit_previous_captures_or_clock
    first = Turn.new(@player)
    Time.stub(:now, Time.at(0)) { first.startSowing }
    [0, 7].each { |column| first.recordCapture(column) }
    second = Turn.new(@player)
    refute second.capturedBothEnds
    Time.stub(:now, Time.at(500)) { refute second.isTimedOut }
  end

  def capture_fixture(player_id = 1, column = 0, seeds = [3, 5])
    player = Player.new(player_id, "Player #{player_id}")
    inner = player_id == 1 ? 2 : 1
    landing = TestPit.new(inner, column, 4)
    opponent_rows = player_id == 1 ? [1, 0] : [2, 3]
    opposing = seeds.each_with_index.map { |count, i| TestPit.new(opponent_rows[i], column, count) }
    board = TestBoard.new({player_id => TestSide.new(inner)}, {landing.object_id => opposing})
    [Capture.new(board, player, landing), landing, opposing, Turn.new(player)]
  end

  def test_capture_is_possible_for_both_players_without_mutating_pits
    [1, 2].each do |id|
      capture, landing, opposing, = capture_fixture(id)
      assert capture.isPossible
      assert capture.isPossible
      assert_equal 4, landing.getSeeds
      assert_equal [3, 5], opposing.map(&:getSeeds)
    end
  end

  def test_capture_requires_both_opposing_pits_to_hold_seeds
    [[0, 5], [3, 0], [0, 0]].each do |seeds|
      capture, _, opposing, = capture_fixture(1, 0, seeds)
      refute capture.isPossible
      assert_equal seeds, opposing.map(&:getSeeds)
    end
  end

  def test_capture_rejects_outer_row_before_requesting_opposing_pits
    board = Minitest::Mock.new
    side = Minitest::Mock.new
    landing = TestPit.new(3, 0, 4)
    board.expect(:getSide, side, [@player])
    side.expect(:isInner, false, [landing])
    refute Capture.new(board, @player, landing).isPossible
    board.verify
    side.verify
  end

  def test_capture_returns_all_removed_seeds_and_preserves_landing_pit
    [1, 2].each do |id|
      capture, landing, opposing, turn = capture_fixture(id)
      assert capture.isPossible
      assert_equal 8, capture.execute(turn)
      assert_equal [0, 0], opposing.map(&:getSeeds)
      assert_equal 4, landing.getSeeds
      refute capture.isPossible
    end
  end

  def test_capture_records_column_for_emitwe_ebiri
    turn = Turn.new(@player)
    [0, 7].each do |column|
      capture, = capture_fixture(1, column)
      capture.execute(turn)
    end
    assert turn.capturedBothEnds
  end

  def test_landing_occupancy_is_callers_responsibility
    capture, landing, = capture_fixture
    landing.seeds = 1
    assert capture.isPossible
  end

  def test_capture_helper_is_private
    assert_includes Capture.private_instance_methods(false), :hasSeedsInAll
    refute_includes Capture.public_instance_methods(false), :hasSeedsInAll
  end
end
