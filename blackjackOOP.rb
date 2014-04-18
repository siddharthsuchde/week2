
class Card
  attr_accessor :value, :suit
  def initialize(v,s)
    @value = v
    @suit = s
  end

  def to_s
    # access the Getter via #{value} 
    # NOT #{@value}. Don't acces instance method directly
    # esp. useful when trying to hide info
    # e.g. social security no. Create a Getter method to hide
    # all numbers in Social Sec number except last 2 or 3
    # therefore modify output. 
    # Instance Variables if called directly will show entire value/form.
    "This card is #{value} of #{suit}"
  end

  def find_suit
    # case statements some in conjunction with "when"
    # exactly the same thing as an if, elsif, elsif statement
    # don't have to put "ret_value" still works
    ret_value = case suit
                when 'H' then 'Hearts'
                when 'S' then 'Spades'
                when 'D' then 'Diamonds'
                when 'C' then 'Clubs'
                end
    ret_value
  end
end
# temptation to put a total_value method however
# in each card game value will defer 
# e.g. Ace is different in Poker and Blackjack
# these properties and methods (verbs) should
# mimic that of an actual card.
# we are NOT thinking of the context of the game
# abstractly ONLY about the Card. 


class Deck
  # Deck class is just some collection of cards
  # attr_accessor if we want to call the "cards" method on deck (or any) object
  attr_accessor :cards 
  def initialize
    # a deck is basically an array of cards
    @cards = []
    ['Spades', 'Clubs', 'Hearts', 'Diamonds'].each do |suit|
      ['2','3','4','5','6','7','8','9','10','J','K','Q','A'].each do |value|
        # now we create an Array (@class) of Cards Object. Procedural game 
        # it was a Nested Array
        # now we can actually put Card objects into the array
        @cards << Card.new(value,suit)
      end
    end

    shuffle
  end

  def shuffle
    # "shuffle!" comes from shuffling an array
    # shuffle method in built into arrays
    # cards is an array
    cards.shuffle!
  end

  def deal_one
    # don't want to acces instance variables directly
    cards.pop 
  end

  def size
    # can also do deck.cards.size but decoupling always better
    # allows you to filter/add/interject
    # e.g. if you want to say "The size is ..."
    cards.size
  end
end

module Hand
  # used for injecting similar behavior into Classes
  # in this case Player and dealer Class

  def show_hand
    puts "----#{name}'s hand ----"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "Total => #{total}"
  end

  def total
    # get the face value through Getter method .value
    value  = cards.map {|e| e.value}
  # new array of cards with 
  total = 0
  value.each do |face_value|
    if face_value.to_i == 0 && face_value !=  'A'
      total += 10
    elsif face_value.to_i == 0 && face_value == 'A'
      total += 11
    else
      total += face_value.to_i
    end
  end
  # correct for Aces : glanced at solutions for this step!
  if value.include?('A') && total > 21
    total -= 10
  end
  total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > 21
    
  end
end



class Player
  include Hand
  attr_accessor :name, :cards 

  def initialize(n)
    @name = n
    @cards = []
  end

end


class Dealer
  include Hand
  attr_accessor :name, :cards 

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_hand
    puts "----#{name}'s hand ----"
    puts "The Dealer's first card is hidden"
    puts "#{cards[1]}"
  end
end


class Blackjack
  # this is the engine of the game
  # need to initialize the game
  attr_accessor :player, :dealer, :deck

  def initialize
    @player = Player.new("Bob")
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def start
    set_player_name
    deal_cards
    show_hand
    player_turn
    dealer_turn
    who_won?
  end

  def set_player_name
    puts "What's players name?"
    player.name = gets.chomp
    puts "#{player.name} is ready to play blackjack!"
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end

  def show_hand
    player.show_hand
    dealer.show_hand
  end

  def blackjack_or_busted?(player_or_dealer)
    if player_or_dealer.total == 21 
      if player_or_dealer.is_a?(Dealer)
        puts "You lose! Dealer Wins. Blackjack!!"
        exit
      else 
        puts "Blackjack! #{player.name} wins! Congratulations!"
        exit 
      end

    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Player)
        puts "Busted! #{player.name}'s total is #{player.total}. You lose!"
        exit
      elsif player_or_dealer.is_a?(Dealer)
        puts "Dealer's total is #{dealer.total}. Dealer us bust. #{player.name} wins!!"
        exit
      end
    end
  end

  def player_turn
    blackjack_or_busted?(player)

    while !player.is_busted?
      puts "What would you like to do: hit or stay?"
      player_choice = gets.chomp
      if player_choice == "hit"
        new_card = deck.deal_one
        player.add_card(new_card)
        puts "#{player.name}'s new card: #{new_card}"
        puts "#{player.name}'s new total is: #{player.total}"
        blackjack_or_busted?(player)
      elsif player_choice == "stay"
        puts "#{player.name} chooses to stay"
        puts "Now it's the Dealer's turn."
        break
      else
        puts "Please enter a valid response: hit or stay?"
      end
    end
  end

  def dealer_turn
    blackjack_or_busted?(dealer)

    while dealer.total < 17
      puts "Dealer choses to hit"
      new_card = deck.deal_one
      puts "Dealers new card: #{new_card}"
      dealer.add_card(new_card)
      puts "Dealers new total is: #{dealer.total}"
      blackjack_or_busted?(dealer)
    end

    if dealer.total >= 17 && dealer.total < 21
      puts "The Dealers total is #{dealer.total}"
      puts "The Dealer decides to stay"
    end
  end

  def who_won?
    if player.total > dealer.total
      puts "#{player.name} wins! Congratulations!"
    elsif player.total < dealer.total 
      puts "Dealer Wins! Better luck next time."
    else
      puts "It's a tie!"
    end
  end
end


game1 = Blackjack.new
game1.start
