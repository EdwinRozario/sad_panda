require 'sad_panda/helpers'

module SadPanda
  # Creates the word frequencies for actual word stems
  class WordFrequency
    include Helpers

    attr_reader :words, :text

    def initialize(text)
      @text = text
    end

    def call
      words_in
      @words = remove_stopwords_in
      @words = stems_for
      frequencies_for
    end

    private

   # Returns a Hash of frequencies of each uniq word in the text
    def frequencies_for
      word_frequencies = {}
      words.each { |word| word_frequencies[word] = words.count(word) }
      word_frequencies
    end

    # Converts all the words to its stem form
    def stems_for
      stemmer = Lingua::Stemmer.new(language: 'en')
      words.map! { |word| stemmer.stem(word) }
    end

    # Strips the words array of stop words
    def remove_stopwords_in
      words - SadPanda::Bank::STOPWORDS
    end

    # Removing non ASCII characters from text
    def sanitize
      @text.gsub!(/[^a-z ]/i, '')
      @text.gsub!(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/, '')
      @text.gsub!(/(?=\w*h)(?=\w*t)(?=\w*t)(?=\w*p)\w*/, '')
      @text.gsub!(/\s\s+/, ' ')

      @text.downcase    
    end

    # Removes all the unwated characters from the text
    def words_in
      @words = emojies_in + sanitize.split
    end

    # Captures and returns emojies in the text
    def emojies_in
      (sad_emojies + happy_emojies).map do |emoji|
        @text.scan(emoji)
      end.flatten
    end    
  end
end