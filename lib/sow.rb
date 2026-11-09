require_relative "capture"

class Sow
  def initialize(turn, board, side)
  end

  def sow(startingPit)
    raise NotImplementedError, "#{self.class} must implement sow"
  end

  private

  def distribute(path, startingPit, seeds, direction)
  end

  def canReverseSow(pit)
  end
end
