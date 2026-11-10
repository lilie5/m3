require_relative "pit"
require_relative "side"

class Board
  ROWS = 4
  COLUMNS = 8
  SIDE_ROWS = 2

  def initialize(first, second)
      @pits = []
      @sides = []

      (0...ROWS).each do |row|
        (0...COLUMNS).each do |column|
          @pits << Pit.new(row, column)
        end
      end
  end

  def getSide(player)
  end

  def getOpponentSide(player)
  end

  def getPit(row, column)
  end

  def getOpposingPits(pit)
  end
end
