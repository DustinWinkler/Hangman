require 'yaml'

def print_word(word, guesses)
  to_print = []
  word.split('').each do |letter|
    guesses.include?(letter) ? to_print.push(letter) : to_print.push('_')
  end
  puts to_print.join
end

def check_guess(letter, word, guesses, incorrect)
  if word.split('').include?(letter)
    guesses.push(letter)
  else
    puts 'That letter is not in the word'
    unless incorrect.include?(letter)
      incorrect.push(letter)
    end
  end
end

def win?(guesses, word)
  word.split('').all? { |letter| guesses.include?(letter) }
end

list = File.readlines "5desk.txt"
$dictionary = []
list.each do |word|
  if word.chomp.length >= 5 && word.chomp.length <= 12
    $dictionary.push(word.chomp)
  end
end

class Game
  attr_accessor :word, :correct_guesses, :incorrect_guesses, :turns
  def initialize
    @word = $dictionary.sample.downcase
    @correct_guesses = []
    @incorrect_guesses = []
    @turns = 1
  end
end

saves = Dir.children('Saves') 
save_opened = false
puts "Would you like to load a save? Y/N?"
choice = gets.chomp.upcase
until choice == 'Y' || choice == 'N'
  puts 'That was not a valid choice. Try again.'
  choice = gets.chomp
end

if choice == 'N'
  game = Game.new
elsif saves.empty?
  puts 'There are no save files. We will start a new game'
  sleep(2)
  game = Game.new
elsif choice == 'Y' && !saves.empty?
  save_opened = true
  puts 'Which save would you like to load?'
  puts saves
  save = gets.chomp
  until saves.include?(save)
    puts 'That was not a valid choice, try again'
    save = gets.chomp
  end 
  opensave = File.open("Saves/#{save}", 'r+')
  game = YAML::load(opensave)
end
# finish serialization
# check if saves exist as well
puts "You must guess the word before 6 incorrect guesses, If you would like to save at any time type 1"
until game.incorrect_guesses.length > 5 || win?(game.correct_guesses, game.word)
  print_word(game.word, game.correct_guesses)
  puts "What is your guess? (Single letter) Incorrect guesses: #{game.incorrect_guesses.join}"
  guess = gets.chomp.downcase.split('').shift
  if guess == '1'
    newsave = YAML::dump(game)
    puts "What you like to title this save?"
    name = gets.chomp
    File.open("Saves/#{name}", 'w').write(newsave)
    exit
  else
    until guess.match?(/[a-z]/)
      puts 'Your guess must be a letter'
      guess = gets.chomp.downcase.split('').shift
    end
  end
  check_guess(guess, game.word, game.correct_guesses, game.incorrect_guesses)
  game.turns += 1
end

if save_opened
  File.delete(opensave)
end

if win?(game.correct_guesses, game.word)
  puts "You guessed the word! Good job! The word was #{game.word}"
elsif !win?(game.correct_guesses, game.word)
  puts "You did not guess the word in time :( The word was #{game.word}"
end
