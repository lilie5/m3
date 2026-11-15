require_relative "player"
require_relative "board"
require_relative "turn"
require_relative "forward_sow"
require_relative "reverse_sow"

class OmwesoGameEngine
  SEEDS_PER_PLAYER = 32 #constant, initial total seeds per player

  def initialize(name1, name2)
    @players = [Player.new(1,name1), Player.new(2, name2)] 
    @board = Board.new(@players[0], @players[1])
    @state = :SETUP
    @setupPlayer = @players[0]
    @seedsLeft = SEEDS_PER_PLAYER
    @turn = nil
    @winner = nil
    @victoryType = nil
    @reversePit = nil
  end

  #Getter/Acessor methods
  def getBoard
    @board
  end

  def getPlayer(number)
    @players.find { |player| player.getId == number }
  end

  def getCurrentPlayer
    @turn&.getPlayer()
  end

  def getSetupPlayer
    return unless @state != :SETUP
    @setupPlayer
  end

  def getSeedsLeft
    @seedsLeft
  end

  def getState
    @state
  end

  def getWinner
    return unless @state != :WON
    @winner
  end

  def getVictoryType
    return unless @state != :WON
    @victoryType
  end

  def getReversePit
    @reversePit
  end

  def placeSeeds(row, column, count)
    pit = ownPit(@setupPlayer, row, column)

    if count < 0 || count > @seedsLeft + pit.getSeeds()
      raise ArgumentError, "BAD_SEED_COUNT"
    end

    @seedsLeft = @seedsLeft + pit.getSeeds() - count 
    pit.setSeeds(count)
  end

  def finishSetup
    raise ArgumentError, "SEEDS_LEFT" if @seedsLeft > 0 #seeds still need to be placed

    if @setupPlayer == @players[0] #P1 has set up, moving to P2
      @setupPlayer = @players[1]
      @seedsLeft = SEEDS_PER_PLAYER #reset seed count for P2
    else
      @setupPlayer = nil #P2 has set up
      @turn = Turn.new(@players.sample) #random player selected for Turn
      @state = :IN_PROGRESS #game state set
    end
  end

  def takeTurn(row, column, reverse)

    #step 1
    player = @turn.getPlayer
    opponent = @players.find { |otherPlayer| otherPlayer != player } #finds who is not taking the turn
    startingPit = ownPit(player, row, column)
    if @reversePit && startingPit != @reversePit #if reversepit
      raise ArgumentError, "NOT_THE_PAUSED_PIT"
    end

    # step 2: sowing
    side = @board.getSide(player)
    sow = reverse ? ReverseSow.new(@turn, @board, side) : ForwardSow.new(@turn, @board, side)
    
    # step 3
    reversePit = sow.sow(startingPit)
    @reversePit = reversePit
    return if reversePit #turn paused, View calls takeTurn again with that pit.

    #step 4 - game end check
    if @turn.isTimedOut #has time ran out?
      endGame(opponent, :TIME) 
    elsif !side.hasLegalMove #can the current player play any move?
      endGame(opponent, :IMMOBILIZATION) #oppnenet wins
    elsif !@board.getSide(opponent).hasLegalMove #can the oppnonent move?
      endGame(player, :IMMOBILIZATION) #curr player wins
    elsif @turn.capturedBothEnds #turn captured both end columns, game end
      endGame(player, :EMITWE_EBIRI)
    else
      @turn = Turn.new(opponent) # none of the above, switch turns
    end
  end

  private

  def ownPit(player, row, column)
    side = @board.getSide(player)
    pit = @board.getPit(row, column)
    side.owns(pit) ? pit : nil
  end

  def endGame(player, reason)
    @state = :WON
    @winner = player
    @victoryType = reason
  end
end
