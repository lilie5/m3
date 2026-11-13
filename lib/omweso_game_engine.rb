require_relative "player"
require_relative "board"
require_relative "turn"
require_relative "forward_sow"
require_relative "reverse_sow"

class OmwesoGameEngine
  SEEDS_PER_PLAYER = 32

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
  end

  def takeTurn(row, column, reverse)
  end

  private

  def ownPit(player, row, column)
    side = @board.getSide(player)
    pit = @board.getPit(row, column)
    side.owns(pit) ? pit : nil
  end

  def endGame(player, reason)
  end
end
