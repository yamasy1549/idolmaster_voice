require 'nokogiri'
require 'open-uri'
require 'pry'

#
# アイドルのURL一覧を取得
#

idol_list_url = 'http://seesaawiki.jp/imascg/d/%a5%dc%a5%a4%a5%b9%c9%d5%a4%ad%a5%a2%a5%a4%a5%c9%a5%eb%b0%ec%cd%f7'

html = open(idol_list_url).read
doc = Nokogiri::HTML.parse(html, nil, nil)

idol_list = doc.css("tr td a")[0...59].map do |node|
  url1 = node[:href]

  html = open(url1).read
  doc = Nokogiri::HTML.parse(html, nil, nil)

  urls = doc.css(".title-1").map do |node|
    next unless node.inner_text == "同名アイドル "
    list = node.next_sibling.next_sibling
    list.css("a").map do |a|
      a[:href]
    end
  end

  [url1, *urls.flatten.compact]
end


#
# アイドルごとの台詞一覧を取得
#

voices = idol_list.flatten.map do |url|
  idol_url = url

  html = open(idol_url).read
  doc = Nokogiri::HTML.parse(html, nil, nil)

  doc.css(".title-2").map do |node|
    next unless node.inner_text == "セリフ集 "
    table = node.next_sibling.next_sibling
    table.css("td").map do |td|
      text = td.inner_text
      text.gsub!(/【.+?】/, "")
      text.gsub!(/\(.+?\)/, "")
      text.gsub!(/（.+?）/, "")
      text.gsub!(/^[\t\s]+/, "")
      text if text.length >= 20
    end
  end
end

#
# 保存
#

File.open("voice_cinderella.txt", "w") do |f|
  f.puts voices.flatten.compact
end
