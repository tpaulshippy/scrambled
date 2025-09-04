class WordService
  WORDS = %w[
    apple banana orange grape lemon cherry
    house table chair window mirror carpet
    happy smile laugh dance music party
    ocean beach sunny cloud storm water
    friend family loved trust peace heart
    pizza bread salad pasta cheese butter
    phone computer screen keyboard mouse laptop
    garden flower plant green grass trees
    bright lights color paint brush canvas
    travel flight train journey adventure explore
    coffee breakfast dinner lunch snack sweet
    school learn study books write reading
    sports games soccer tennis running jumping
    morning evening sunset sunrise daylight shadow
    mountain forest river valley meadow stream
  ].freeze

  def self.random_word
    WORDS.sample
  end

  def self.scramble(word)
    return word if word.length <= 1

    scrambled = word.chars.shuffle
    while scrambled.join == word
      scrambled = word.chars.shuffle
    end

    scrambled.join
  end

  def self.validate_word(word)
    return false unless word.is_a?(String)
    WORDS.include?(word.downcase)
  end
end
