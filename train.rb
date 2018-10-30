require 'pry'
require 'MeCab'
require 'ruby-progressbar'
require 'pycall/import'
include PyCall::Import

pyfrom 'sklearn.model_selection', import: :train_test_split
pyfrom 'sklearn.linear_model', import: :LogisticRegression
pyfrom 'sklearn.externals', import: :joblib

class String
  def to_word_freqs
    freqs = {}
    tagger = MeCab::Tagger.new('-Owakati')

    tagger.parse(self).split.each do |word|
      # if word.use_as_feature?
        freqs[word] ||= 0
        freqs[word] += 1
      # end
    end

    freqs
  end
end

#
# 単語の出現頻度をとる
#
def word_freqs(filename: 'voice.txt', sentences: nil)
  freqs = []

  if sentences
    progressbar = ProgressBar.create(title: 'Freqs', total: sentences.count)
    freqs = sentences.map do |sentence|
      progressbar.increment
      sentence.to_word_freqs
    end
  else
    progressbar = ProgressBar.create(title: 'Freqs', total: `wc -l #{filename}`.to_i)
    File.open(filename) do |file|
      freqs = file.map do |line|
        progressbar.increment
        line.scrub('?').chomp[2...-1].to_word_freqs
      end
    end
  end

  progressbar.finish
  freqs
end

#
# BoW構築
#
def bag_of_words(at_least: 3)
  freqs = word_freqs
  _bow = {}

  freqs.each do |freq|
    freq.each do |word, count|
      _bow[word] ||= 0
      _bow[word] += count
    end
  end

  # 単語の出現回数がat_least回以上のものだけ
  words = _bow.select{ |_, count| count >= at_least }.keys
  bow = words.product([0]).to_h

  if block_given?
    yield(words, freqs, bow)
  else
    progressbar = ProgressBar.create(title: 'Bows', total: freqs.count)
    bows = freqs.map do |freq|
      progressbar.increment
      freq_bow = bow.clone
      freq.each do |word, count|
        freq_bow[word] += count if words.include?(word)
      end
      freq_bow.values
    end
    progressbar.finish

    return words, bows
  end
end

#
# 訓練データとテストデータを分ける
#
def train_test_data(filename: 'voice.txt', test_size: 0.3)
  labels = File.open(filename).each_line.map do |line|
    line[0] == "c" ? 0 : 1
  end

  _, bows = bag_of_words
  train_test_split(bows, labels, test_size: test_size)
end

#
# 線形回帰する
#
def logreg(x_train, y_train)
  model = LogisticRegression.()
  model.fit(x_train, y_train)
end
