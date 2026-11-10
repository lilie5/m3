require_relative "pit"

class Node
  
  def initialize(pit)
    @pit = pit
    @next = nil
    @prev = nil
  end

  def next(count)
    raise ArgumentError, "count must not be negative" if count < 0

    node = self
    count.times { node = node.getNext }
    node.getPit
  end

  def prev(count)
    raise ArgumentError, "count must not be negative" if count < 0

    node = self
    count.times { node = node.getPrev }
    node.getPit
  end

  def getNext
    @next
  end

  def getPrev
    @prev
  end

  def getPit
    @pit
  end

  def setNext(node)
    @next = node
  end

  def setPrev(node)
    @prev = node
  end
end
