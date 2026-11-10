class Capture

  def initialize(board, player, landingPit)
    @board = board
    @landingPit = landingPit
    @side = board.getSide(player)
  end

  # The sowing caller checks that the landing pit was previously occupied.
  def isPossible
    @side.isInner(@landingPit) && hasSeedsInAll(@board.getOpposingPits(@landingPit))
  end

  # The caller must establish isPossible before executing the capture.
  def execute(turn)
    turn.recordCapture(@landingPit.getColumn)
    @board.getOpposingPits(@landingPit).sum { |pit| pit.removeAllSeeds }
  end

  private

  def hasSeedsInAll(pits)
    pits.all? { |pit| pit.getSeeds > 0 }
  end
end
