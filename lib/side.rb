require_relative "doubly_linked_list"

class Side
  PIT_COUNT = 16

  def initialize(board, player)
    @board = board
    @player = player
    @path = DoublyLinkedList.new()
  end

  def getPlayer
    @player
  end

  def getOuterRow
    if @player.getId == 1
      return 0
    else
      return 3
    end
  end

  def getInnerRow
    if @player.getId == 1
      return 1
    else
      return 2
    end
  end

  def getPath
    @path
  end

  def owns(pit)
  end

  def isInner(pit)
  end

  def isReversePit(pit)
  end

  def hasLegalMove
  end
end
