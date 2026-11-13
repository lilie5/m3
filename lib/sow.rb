require_relative "capture"

class Sow
  def initialize(turn, board, side)
    @turn = turn
    @board = board
    @side = side
  end

  def sow(startingPit)
    raise NotImplementedError, "#{self.class} must implement sow"
  end

  private

  def distribute(path, startingPit, seeds, direction)
    node = path.find(startingPit)
    landingPit = nil
    seeds.times do
      node = direction == :CLOCKWISE ? node.getNext : node.getPrev
      landingPit = node.getPit
      landingPit.addSeed
    end
    landingPit
  end

  def canReverseSow(pit)
    return false unless @side.isReversePit(pit)
    return false unless pit.getSeeds >= 2

    node = @side.getPath.find(pit)
    pit.getSeeds.times { node = node.getNext }
    landingPit = node.getPit
    landingPit != pit && landingPit.getSeeds >= 1 && Capture.new(@board, @side.getPlayer, landingPit).isPossible
  end
end
