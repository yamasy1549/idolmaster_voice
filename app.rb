require './train'

# === 学習

if File.exist?("model.pkl")
  model = joblib.load("model.pkl")
else
  x_train, _, y_train, _ = train_test_data
  model = logreg(x_train, y_train)
  joblib.dump(model, "model.pkl")
  puts "accuracy(train)\t#{model.score(x_train, y_train)}"
end

# === 予測

sentences = [
  # cinderella
  "本田未央15歳。高校一年生ですっ！ 元気に明るく、トップアイドル目指して頑張りまーっす！ えへへ。今日からよろしくお願いしまーす♪",
  "私がトップアイドルになるまで、ちゃーんと面倒みてねっ♪えへへ～、これからも力を合わせて頑張ろーっ！",
  # sidem
  "成り行きで始めた仕事だが､嫌いじゃないぜ｡身体も動かせるしな!"
]

freqs = word_freqs(sentences: sentences)

bows = []
bag_of_words do |words, _, bow|
  bows = freqs.map do |freq|
    freq_bow = bow.clone
    freq.each do |word, count|
      freq_bow[word] += count if words.include?(word)
    end
    freq_bow.values
  end
end

model.predict_proba(bows).tolist.to_a.each.with_index do |probability, i|
  if probability[0] >= probability[1]
    puts "[cinde]\t#{probability[0]}"
  else
    puts "[sidem]\t#{probability[1]}"
  end
  puts "\t#{sentences[i]}"
end
