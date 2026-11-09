require_relative "omweso_game_engine"

class ConsoleView
  LABEL_WIDTH = 28

  def play
    @turnNumber = 0
    puts "==================== OMWESO ===================="
    print "Player 1 name: "
    name1 = readLine.strip
    name1 = "Player 1" if name1.empty?
    print "Player 2 name: "
    name2 = readLine.strip
    name2 = "Player 2" if name2.empty?

    game = OmwesoGameEngine.new(name1, name2)
    arrangeBoard(game)

    until game.getState == :WON
      @turnNumber += 1
      player = game.getCurrentPlayer
      side = game.getBoard.getSide(player)

      puts
      puts "================ Turn #{@turnNumber} - #{player.getName} (Player #{player.getId}) ================"
      puts
      showBoard(game)
      puts
      puts "You have #{Turn::TIME_LIMIT / 60} minutes once you pick a pit. The clock is checked at each sow."

      loop do
        puts
        reverse = readYesNo("Reverse sow? (y/n): ")
        row = readNumber("Row of the pit to sow from (#{side.getInnerRow + 1} inner or #{side.getOuterRow + 1} outer): ", Board::ROWS)
        column = readNumber("Column of the pit to sow from (1-#{Board::COLUMNS}): ", Board::COLUMNS)
        begin
          game.takeTurn(row - 1, column - 1, reverse)
          break
        rescue ArgumentError => error
          puts rejectionMessage(error.message, game, row, column)
        end
      end

      while (pit = game.getReversePit)
        row = pit.getRow + 1
        column = pit.getColumn + 1
        puts
        puts "The last seed landed in row #{row}, column #{column}, one of your reverse pits."
        reverse = readYesNo("Reverse sow from there? (y/n): ")
        begin
          game.takeTurn(pit.getRow, pit.getColumn, reverse)
        rescue ArgumentError => error
          puts rejectionMessage(error.message, game, row, column)
        end
      end

      #takeTurn returns void and the engine has no move log? but the UI seems different
      puts
      puts "#{player.getName}'s turn is over."
      break if game.getState == :WON

      puts
      showBoard(game)
      nextPlayer = game.getCurrentPlayer
      puts
      print "#{nextPlayer.getName} (Player #{nextPlayer.getId}), it is your turn. Press Enter to see the board."
      readLine
    end

    puts
    showBoard(game)
  end

  def showBoard(game)
    state = game.getState
    board = game.getBoard
    bottom = game.getPlayer(1)
    top = game.getPlayer(2)
    
    viewer = state == :SETUP ? game.getSetupPlayer : game.getCurrentPlayer
    indent = " " * LABEL_WIDTH
    width = Board::COLUMNS * 5 + 1
    border = indent + "+" + (["----"] * Board::COLUMNS).join("+") + "+"
    divider = indent + "+" + (["===="] * Board::COLUMNS).join("+") + "+"
    topLabel = "#{top == viewer ? 'You' : 'Opponent'}: #{top.getName} (Player #{top.getId})"
    bottomLabel = "#{bottom == viewer ? 'You' : 'Opponent'}: #{bottom.getName} (Player #{bottom.getId})"

    puts((indent + topLabel.center(width)).rstrip)
    puts columnLabels
    puts border
    (0...Board::ROWS).each do |row|
      puts boardRow(game, row)
      puts(row == Board::SIDE_ROWS - 1 ? divider : border)
    end
    puts((indent + bottomLabel.center(width)).rstrip)

    if state == :SETUP
      left = game.getSeedsLeft
      puts "Seeds placed: #{OmwesoGameEngine::SEEDS_PER_PLAYER - left}   Left to place: #{left}"
      return
    end

    totals = [bottom, top].map do |player|
      side = board.getSide(player)
      seeds = [side.getInnerRow, side.getOuterRow].sum do |row|
        (0...Board::COLUMNS).sum { |column| board.getPit(row, column).getSeeds }
      end
      "#{player.getName}: #{seeds}"
    end
    puts "  * = reverse pit".ljust(LABEL_WIDTH) + "Seeds - " + totals.join("   ")

    if state == :WON
      winner = game.getWinner
      how = {
        IMMOBILIZATION: "by immobilization: the opponent has no pit with 2 or more seeds",
        TIME: "on time: the opponent's turn went over #{Turn::TIME_LIMIT / 60} minutes",
        EMITWE_EBIRI: "by Emitwe-ebiri: both of the opponent's end columns were captured in one turn"
      }[game.getVictoryType]
      puts
      puts "#{winner.getName} (Player #{winner.getId}) wins #{how}."
    else
      current = game.getCurrentPlayer
      puts "Turn: #{current.getName} (Player #{current.getId})"
    end
  end

  def columnLabels
    ("Col".ljust(LABEL_WIDTH + 1) + (1..Board::COLUMNS).map { |column| format("%3d ", column) }.join(" ")).rstrip
  end

  def boardRow(game, row)
    board = game.getBoard
    firstPit = board.getPit(row, 0)
    owner = [game.getPlayer(1), game.getPlayer(2)].find { |player| board.getSide(player).owns(firstPit) }
    side = board.getSide(owner)
    kind = side.isInner(firstPit) ? "inner" : "outer"
    #UI hides a side that has not been set up yet
    hidden = game.getState == :SETUP && owner.getId > game.getSetupPlayer.getId
    name = owner.getName[0, LABEL_WIDTH - 18]

    cells = (0...Board::COLUMNS).map do |column|
      pit = board.getPit(row, column)
      hidden ? "    " : format("%3d%s", pit.getSeeds, side.isReversePit(pit) ? "*" : " ")
    end
    " Row #{row + 1} (#{kind}, #{name})".ljust(LABEL_WIDTH) + "|" + cells.join("|") + "|"
  end

  def rejectionMessage(code, game, row, column)
    board = game.getBoard
    player = game.getState == :SETUP ? game.getSetupPlayer : game.getCurrentPlayer
    side = board.getSide(player)
    pit = row && column ? board.getPit(row - 1, column - 1) : nil
    if pit
      inner = [game.getPlayer(1), game.getPlayer(2)].any? { |p| board.getSide(p).isInner(pit) }
      where = "row #{row} (#{inner ? 'inner' : 'outer'}), column #{column}"
    end

    case code
    #ownPit error's code never gets named so i just put it as "NOT_YOUR_PIT"
    when "NOT_YOUR_PIT"
      rows = [side.getInnerRow, side.getOuterRow].sort.map { |r| r + 1 }
      "That pit is not yours. Rows #{rows.join(' and ')} are yours."
    when "TOO_FEW_SEEDS"
      seeds = pit.getSeeds
      "That pit holds #{seeds} seed#{'s' unless seeds == 1}. Choose a pit with at least 2 seeds."
    when "NOT_A_REVERSE_PIT"
      #the UI is hard-coding 1-2 but we need to derive them from the Sides here
      columns = (0...Board::COLUMNS).select { |c| side.isReversePit(board.getPit(side.getInnerRow, c)) }.map { |c| c + 1 }
      "#{where.capitalize} is not a reverse pit. Reverse pits are marked * (columns #{columns.first}-#{columns.last} of your rows)."
    when "NO_CAPTURE"
      "A reverse sow from #{where} would not end in a capture.\nChoose again."
    when "NOT_THE_PAUSED_PIT"
      paused = game.getReversePit
      "Your turn is paused on row #{paused.getRow + 1}, column #{paused.getColumn + 1}. Continue from that pit."
    when "BAD_SEED_COUNT"
      max = game.getSeedsLeft + pit.getSeeds
      "You only have #{max} seed#{'s' unless max == 1} left. Enter a number from 0 to #{max}."
    when "SEEDS_LEFT"
      left = game.getSeedsLeft
      "You still have #{left} seed#{'s' unless left == 1} to place."
    else
      raise ArgumentError, code
    end
  end

  private

  def arrangeBoard(game)
    while game.getState == :SETUP
      player = game.getSetupPlayer
      side = game.getBoard.getSide(player)
      rows = [side.getInnerRow, side.getOuterRow].sort
      shownRows = rows.map { |row| row + 1 }

      askCount = lambda do |row, column|
        loop do
          left = game.getSeedsLeft
          print "Row #{row + 1}, Column #{column + 1} - seeds to place (#{left} left): "
          count = readNumberFromLine
          begin
            game.placeSeeds(row, column, count)
            return
          rescue ArgumentError => error
            puts rejectionMessage(error.message, game, row + 1, column + 1)
          end
        end
      end

      puts
      puts "---------- Setup: #{player.getName} (Player #{player.getId}) ----------"
      puts "You have #{game.getSeedsLeft} seeds to place on your side (rows #{shownRows.join(' and ')})."
      puts "Any combination is allowed and empty pits are fine."
      puts

      rows.each do |row|
        (0...Board::COLUMNS).each do |column|
          break if game.getSeedsLeft == 0
          askCount.call(row, column)
        end
      end
      puts "No seeds left. The remaining pits stay empty." if game.getSeedsLeft == 0

      loop do
        left = game.getSeedsLeft
        puts
        #this only shows up if the player has cleared a pit and still has seeds left to place
        if left == 0
          puts "Your setup:"
          puts
          showBoard(game)
          puts
          break if readYesNo("Confirm this setup? (y/n): ")
          puts
          puts "Which pit do you want to change?"
        else
          puts "You still have #{left} seed#{'s' unless left == 1} to place. Choose a pit."
        end

        row = readNumber("Row #{shownRows.join(' or ')}: ", Board::ROWS)
        column = readNumber("Column (1-#{Board::COLUMNS}): ", Board::COLUMNS)
        old = game.getBoard.getPit(row - 1, column - 1).getSeeds
        begin
          game.placeSeeds(row - 1, column - 1, 0)
        rescue ArgumentError => error
          puts rejectionMessage(error.message, game, row, column)
          next
        end
        if old > 0
          left = game.getSeedsLeft
          puts "Row #{row}, Column #{column} cleared. You have #{left} seed#{'s' unless left == 1} left to place."
        end
        askCount.call(row - 1, column - 1)
        puts "No seeds left." if game.getSeedsLeft == 0
      end

      game.finishSetup
      puts
      if game.getState == :SETUP
        print "#{player.getName}'s setup is locked in. #{game.getSetupPlayer.getName}, press Enter to arrange your side."
      else
        first = game.getCurrentPlayer
        puts "#{player.getName}'s setup is locked in. Both setups are confirmed."
        print "#{first.getName} (Player #{first.getId}) was chosen at random to go first. Press Enter to start."
      end
      readLine
    end
  end

  def readNumber(prompt, max)
    print prompt
    loop do
      number = readNumberFromLine
      return number if number.between?(1, max)
      puts "Enter a number from 1 to #{max}."
      print prompt
    end
  end

  def readNumberFromLine
    loop do
      line = readLine.strip
      return line.to_i if line.match?(/\A\d+\z/)
      print "Enter a whole number: "
    end
  end

  def readLine
    line = $stdin.gets
    if line.nil?
      puts
      puts "Input ended."
      exit
    end
    line.chomp
  end

  def readYesNo(prompt)
    print prompt
    loop do
      answer = readLine.strip.downcase
      return true if %w[y yes].include?(answer)
      return false if %w[n no].include?(answer)
      puts "Enter y or n."
      print prompt
    end
  end
end
