require_relative "player"
require_relative "board"
require_relative "turn"
require_relative "forward_sow"
require_relative "reverse_sow"

class OmwesoGameEngine
  SEEDS_PER_PLAYER = 32

  def initialize(name1, name2)
  end

  def getBoard
  end

  def getPlayer(number)
  end

  def getCurrentPlayer
  end

  def getSetupPlayer
  end

  def getSeedsLeft
  end

  def getState
  end

  def getWinner
  end

  def getVictoryType
  end

  def getReversePit
  end

  def placeSeeds(row, column, count)
  end

  def finishSetup
  end

  def takeTurn(row, column, reverse)
  end

  private

  def ownPit(player, row, column)
  end

  def endGame(player, reason)
  end
end
