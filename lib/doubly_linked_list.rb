require_relative "node"

class DoublyLinkedList

  def initialize(pits)
    @head = nil
    @length = 0
    pits.each { |pit| append(pit) }
  end

  def append(pit)

    node = Node.new(pit)

    if @head.nil?
      node.setNext(node)
      node.setPrev(node)
      @head = node
    else
      last = @head.getPrev
      last.setNext(node)
      node.setPrev(last)
      node.setNext(@head)
      @head.setPrev(node)
    end

    @length += 1

  end

  def find(pit)

    node = @head

    @length.times do
      return node if node.getPit.equal?(pit)

      node = node.getNext
    end

    nil
  end
end
