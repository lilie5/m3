require "set"

class Turn
  
  TIME_LIMIT = 180

  def initialize(player)
    @player = player
    @capturedEnds = Set.new
    @startedAt = nil
  end

  def getPlayer
    @player
  end

  def isTimedOut
    !@startedAt.nil? && Time.now - @startedAt > TIME_LIMIT
  end

  def startSowing
    @startedAt = Time.now if @startedAt.nil?
  end

  def recordCapture(column)
    @capturedEnds.add(column)
  end

  def capturedBothEnds
    @capturedEnds.include?(0) && @capturedEnds.include?(7)
  end
end
