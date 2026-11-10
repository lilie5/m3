require_relative "doubly_linked_list"

class Side

  PIT_COUNT = 16

  def initialize(board, player)
    @board = board
    @player = player

    inner_pits = []
    outer_pits = []

    for i in 0...Board::COLUMNS
      inner_pits << @board.getPit(getInnerRow, i)
      outer_pits << @board.getPit(getOuterRow, i)
    end

    # Create a single clockwise list of pits for the players side of the board
    if @player.getId == 1
      path_pits = inner_pits + outer_pits.reverse
    else
      path_pits = outer_pits + inner_pits.reverse
    end

    @path = DoublyLinkedList.new(path_pits)
  end

  def getPlayer
    @player
  end

  def getOuterRow
    @player.getId == 1 ? 3 : 0
  end

  def getInnerRow
    @player.getId == 1 ? 2 : 1
  end

  def getPath
    @path
  end

  def owns(pit)
    if(pit.getRow == getOuterRow || pit.getRow == getInnerRow)
      return true
    else
      return false
    end
  end

  def isInner(pit)
    pit.getRow == getInnerRow
  end

  def isReversePit(pit) # Not sure about this one
    if owns(pit)
      return true
    end
  end

  def hasLegalMove
    player_pits = []

    for i in 0...Board::COLUMNS
      player_pits << @board.getPit(getInnerRow, i)
      player_pits << @board.getPit(getOuterRow, i)
    end

    if(player_pits.any? { |pit| pit.getSeeds >= 2 })
      return true
    else
      return false
    end

  end
end
