require 'nokogiri'
require 'open-uri'

#
# アイドルのURL一覧を取得
#

idol_url_base = 'https://wikiwiki.jp/sidem/'
idol_list_url = 'https://wikiwiki.jp/sidem/%E4%B8%80%E8%A6%A7'

html = open(idol_list_url).read
doc = Nokogiri::HTML.parse(html, nil, nil)

idol_list = doc.css("table.style_table th")[0...46].map do |node|
  idol_url_base + node.css('a').inner_text
end


#
# アイドルごとの台詞一覧を取得
#

voices = idol_list.map do |url|
  idol_url = URI.encode(url)

  html = open(idol_url).read
  doc = Nokogiri::HTML.parse(html, nil, nil)

  doc.css("table.style_table td").map do |node|
    text = node.inner_text
    text.gsub!(/【.+?】/, "")
    text.gsub!(/\(.+?\)/, "")
    text if text.length >= 20
  end.compact
end


#
# 保存
#

File.open("voice_sidem.txt", "w") do |f|
  f.puts voices.flatten.compact
end
