#!/usr/bin/env ruby
# encoding: utf-8
require "cgi"
require "sqlite3";

cgi = CGI.new;
print cgi.header("text/html; charset=utf-8");

player = cgi["player_point"].to_i;
dealer = cgi["dealer_card"].to_i;

if player > 21  or player < 0 or dealer > 11 or dealer < 0 then
	puts "入力値が異常です";
elsif player > 17 then
	player = 17;
end

begin
	db = SQLite3::Database.new("finalrep.db");
	rows = db.execute("select * from strategy where player like ? and dealer like ?;", player, dealer);
	db.close;
rescue => ex
  print <<-EOS
  <html><body><pre>
  <p>error</p>
    #{ex.message}
    #{CGI.escapeHTML(ex.backtrace.join("\n"))}
  </pre></body></html>
	EOS
end

strategy = "";
rows.each{|row|
	if !row[2].empty? then
		strategy = row[2]
	end
}

print <<EOF
<html>
<body>
<h1>BRACK JACK</h1>
<h2>ストラテジー</h2>
EOF


if strategy.empty? then
  puts "<h2>エラー</h2>"
  puts "<p>ストラテジーが登録されていません</p>"
else
  puts "<p>自分のポイントが#{player}で、ディーラーのオープンカードが#{dealer}のとき有効なストラテジーは、</p>";
  puts "<h2>#{strategy}</h2>";
end

print <<EOF
<a href="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/deal.rb">戻る</a>
</body>
</html>
EOF

