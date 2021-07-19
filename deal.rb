#!/usr/bin/env ruby
# encoding: utf-8
require "cgi"
require "cgi/session"

cgi = CGI.new;
print cgi.header("type" => "text/html", "charset" => "utf-8");

session = CGI::Session.new(cgi);

if !cgi["reset"].empty? then
	session.delete;
	session = CGI::Session.new(cgi);
end

dealer = session["dealer"];
player = session["player"];
session.close;

print <<-EOF
  <html>
  <body>
  <h1>BRACK JACK</h1>
  <form action="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/action.rb" method="post">
EOF

 if dealer == nil then
  print <<-EOF
    <p><input type="submit" name="state" value="ゲームスタート"></p>
		</form>
  EOF
 else
  print <<-EOF
    <hr>
    <h2>あなた</h2>
    <p>手札:#{player}</p>
  EOF

  p_point = 0;
  p_point2 = 0;
  for m in player
    q = 0;
    if m.to_i > 10 then
      p = 10;
    elsif m.to_i == 1 then
      p = m.to_i;
      q = 10;
    else
      p = m.to_i;
    end
    p_point = p_point + p;
    p_point2 = p_point2 + p + q;
  end
  if p_point != p_point2 then
    puts "<p>得点:#{p_point}or#{p_point2}<p>";
  else
    puts "<p>得点:#{p_point}<p>";
  end
    
  print <<-EOF
    <h2>ディーラー</h2>
    <p>手札:["??","#{session["dealer"][1]}"]</p>
  EOF

  d_point = 0;
  d_point2 = 0;
  for n in dealer
    q = 0;
    if n.to_i > 10 then
      p = 10;
    elsif n.to_i == 1 then
      p = n.to_i;
      q = 10;
    else
      p = n.to_i;
    end
    d_point = d_point + p;
    d_point2 = d_point2 + p + q;
  end
  puts "<p>得点:??<p>"

  print <<-EOF
    <hr>
    <p>
    <input type="submit" name="state" value="ヒット">
    <input type="submit" name="state" value="スタンド">
    </p>
		</form>
		<form action="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/strategy.rb" method="post">
		<hr>
		<p>
		<input type="number" name="player_point">あなたのポイント
		<input type="number" name="dealer_card">ディーラーのオープンカード
		</p>
		<p><input type="submit" value="有効なストラテジーを見る"></p>
		</form>
  EOF
    
 end

print <<EOF
<form action="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/deal.rb" method="post">
<p><input type="submit" name="reset" value="ゲームをリセット"></p>
</form>
</body>
</html>
EOF

