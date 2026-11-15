class Pit

  def initialize(row, column)
    @seeds = 0
    @row = row
    @column = column
  end

  def getRow
    @row
  end

  def getColumn
    @column
  end

  def getSeeds
    @seeds
  end

  def setSeeds(seeds)
    @seeds = seeds
  end

  def addSeed
    @seeds += 1
  end

  def removeAllSeeds #fix, now returns # of seeds removed
    removed = @seeds
    @seeds = 0
    removed
  end

  def isEmpty?
    @seeds == 0
  end
end
