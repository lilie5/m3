require_relative "sow"

class ForwardSow < Sow
  def initialize(turn, board, side)
    super
  end

  def sow(startingPit)
    raise ArgumentError, "TOO_FEW_SEEDS" unless startingPit.getSeeds >= 2    # not enough seeds to start a sow
    
    @turn.startSowing()
    count = startingPit.removeAllSeeds
    continueSowing(startingPit, count)

  end

  def continueSowing(source, seeds)
    while seeds > 0
      return nil if @turn.isTimedOut() # time has run out, stop
      
      lastPit = distribute(@side.getPath(), source, seeds, :COUNTER_CLOCKWISE)
      return nil if lastPit.getSeeds() == 1 # if the last pit dropped had only 1 seed, stop

      capture = Capture.new(@board, @side.getPlayer(), lastPit) 
        if capture.isPossible()
          seeds = capture.execute(@turn) #capture if possible at the lastPit
        elsif canReverseSow(lastPit) #if not a capture, check if it is in the reverseSow pits
          return lastPit
        else
          seeds = lastPit.removeAllSeeds() #if not any, may go again.
          source = lastPit
        end
      end
    end
    nil
end
