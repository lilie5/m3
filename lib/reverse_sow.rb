require_relative "sow"
require_relative "forward_sow"

class ReverseSow < Sow
  def initialize(turn, board, side)
    super
  end

  def sow(startingPit)
    raise ArgumentError, "NOT_A_REVERSE_PIT" unless @side.isReversePit(startingPit)
    raise ArgumentError, "TOO_FEW_SEEDS" unless startingPit.getSeeds >= 2
    raise ArgumentError, "NO_CAPTURE" unless canReverseSow(startingPit)

    @turn.startSowing
    seeds = startingPit.removeAllSeeds
    landingPit = distribute(@side.getPath, startingPit, seeds, :CLOCKWISE)
    captured = Capture.new(@board, @side.getPlayer, landingPit).execute(@turn)
    ForwardSow.new(@turn, @board, @side).continueSowing(startingPit, captured)
  end
end
