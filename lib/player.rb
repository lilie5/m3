# Owner: Braedan Chappel (Bchappel), issue #1.
class Player
  def initialize(id, name) 

    # id must be 1 or 2 as per the : 
    # "Accessor function to get the player’s id (1 or 2)."
    raise ArgumentError, "id must be 1 or 2" unless [1, 2].include?(id)

    @id = id
    @name = name
  end

  def getId
    @id
  end

  def getName
    @name
  end
end
