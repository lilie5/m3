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
    @sides.find { |side| side.getPlayer == player }
  end

  def getOpponentSide(player)
    @sides.find { |side| side.getPlayer != player }
  end

  def getPit(row, column)
    @pits.find { |pit| pit.getRow == row && pit.getColumn == column }
  end

  def getOpposingPits(pit)

    # From spec: "Returns the opponent’s two pits in the `pit's` column, inner pit first."
    column = pit.getColumn
    
    if pit.getRow <= 1
      return [getPit(2, column), getPit(3, column)]
    else
      return [getPit(1, column), getPit(0, column)]
    end
  end
end
