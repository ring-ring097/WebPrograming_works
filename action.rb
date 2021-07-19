#!/usr/bin/env ruby
# encoding: utf-8
require "cgi"
require "cgi/session" 

cgi = CGI.new;
print cgi.header("type" => "text/html", "charset" => "utf-8");
print <<-EOF
  <html>
  <body>
  <h1>BRACK JACK</h1>
EOF

session = CGI::Session.new(cgi);

#山札
if session["deck"] == nil then
	deck = Array.new(52){|i| i};
else
	deck = session["deck"].dup;
end

#手札
if session["dealer"] == nil then
  dealer = Array.new();
else
  dealer = session["dealer"].dup;
end
if session["player"] == nil then
  player = Array.new();
else
  player = session["player"].dup;
end

#状態
if cgi["state"] == "ゲームスタート" then
  state = 0;
elsif cgi["state"] == "ヒット"
  state = 1;
elsif cgi["state"] == "スタンド"
  state = 2;
else 
  puts "error";
end

#ゲームが終わったかどうか
game_over = 0;

#ゲーム開始時orゲーム中
case state
when 0 then
  #カードをドロー

  #ディーラーの1枚目
  num = rand(deck.length);
  draw = deck[num+1].to_i.modulo(13) + 1;
  deck.delete_at(num+1);
  dealer.push(draw.to_s);
  #ディーラーの2枚目
  num = rand(deck.length);
  draw = deck[num+1].to_i.modulo(13) + 1;
  deck.delete_at(num+1);
  dealer.push(draw.to_s);
  session["dealer"] = dealer;

  #プレイヤーの1枚目
  num = rand(deck.length);
  draw = deck[num+1].to_i.modulo(13) + 1;
  deck.delete_at(num+1);
  player.push(draw.to_s);
  #プレイヤーの2枚目
  num = rand(deck.length);
  draw = deck[num+1].to_i.modulo(13) + 1;
  deck.delete_at(num+1);
  player.push(draw.to_s);
  session["player"] = player;


  #ディーラーのポイント
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
  #プレイヤーのポイント
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

  session["deck"] = deck.dup;

  print <<-EOF
    <h1>始めの手札</h1>
    <h2>あなた</h2>
    <p>手札:#{session["player"]}</p>
  EOF
  if p_point != p_point2 then
    puts "<p>得点:#{p_point}or#{p_point2}<p>";
  else
    puts "<p>得点:#{p_point}<p>";
  end
  print <<-EOF
    <h2>ディーラー</h2>
    <p>手札:["??","#{session["dealer"][1]}"]</p>
    <p>得点:??<p> 
  EOF

when 1, 2 then
  #ディーラーのポイント
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
  #プレイヤーのポイント
  p_point = 0;
  p_point2 = 0;
  for m in player
    q = 0;
    if m.to_i > 10 then
      p = 10;
    elsif m.to_i == 1 then
      p = m.to_i;
      q = 10
    else
      p = m.to_i;
    end
    p_point = p_point + p;
    p_point2 = p_point2 + p + q;
  end

  case state
  #プレイヤーがhit
  when 1,2 then
    #プレイヤー
    print <<-EOF
      <h2>あなた</h2>
    EOF
    case state
    when 1 then
    #プレイヤーがhitの場合
      num = rand(deck.length);
      draw = deck[num+1].to_i.modulo(13) + 1;
      deck.delete_at(num+1);
      puts "<p>ドローカード:#{draw}</p>";
      player.push(draw.to_s);
      q = 0;
      if draw.to_i > 10 then
        p = 10;
      elsif draw.to_i == 1 then
        p = draw.to_i;
        q = 10;
      else
        p = draw.to_i;
      end
      p_point = p_point + p;
      p_point2 = p_point2 + p + q;
      session["player"] = player;
      puts "<p>手札:#{session["player"]}</p>";
      if p_point != p_point2 then
        puts "<p>得点:#{p_point}or#{p_point2}<p>";
      else
        puts "<p>得点:#{p_point}<p>";
      end

      if p_point > 21 then
        puts "<h3>バスト</h3>"
      end

    when 2 then
    #プレイヤーがstandの場合
      print <<-EOF
        <p>スタンドしました</p>
        <p>手札:#{session["player"]}</p>
      EOF
      if p_point != p_point2 then
        puts "<p>得点:#{p_point}or#{p_point2}<p>";
      else
        puts "<p>得点:#{p_point}<p>";
      end
    end

    puts "<hr>";

    #ディーラー
    print <<-EOF
      <h2>ディーラー</h2>
    EOF
    if p_point != p_point2 and p_point <= 21 then
      #プレイヤーのAが有効
      if (p_point2 < d_point and d_point <= 21) or (p_point2 < d_point2 and d_point2 <= 21) then
        #ディーラーが優勢
        #スタンド
        print <<-EOF
          <p>スタンドしました</p>
          <p>手札:#{session["dealer"]}</p>
        EOF
        if d_point != d_point2 then
          puts "<p>得点:#{d_point}or#{d_point2}<p>";
        else
          puts "<p>得点:#{d_point}<p>";
        end
      elsif p_point2 > d_point2 or d_point > 21 then
        #プレイヤーが優勢
        #ヒット
        num = rand(deck.length);
        draw = deck[num+1].to_i.modulo(13) + 1;
        deck.delete_at(num+1);
        puts "<p>ドローカード:#{draw}</p>";
        dealer.push(draw.to_s);
        q = 0;
        if draw.to_i > 10 then
          p = 10;
        elsif draw.to_i == 1 then
          p = draw.to_i;
          q = 10;
        else
          p = draw.to_i;
        end
        d_point = d_point + p;
        d_point2 = d_point2 + p + q;
        session["dealer"] = dealer;
        puts "<p>手札:#{session["dealer"]}</p>";
        if d_point != d_point2 then
          puts "<p>得点:#{d_point}or#{d_point2}<p>";
        else
          puts "<p>得点:#{d_point}<p>";
        end

        if d_point > 21 then
          puts "<h3>バスト</h3>"
        end
      else 
        #引き分け
      end
    else 
      #プレイヤーがAなしor無効
      if (p_point < d_point and d_point <= 21) or (p_point < d_point2 and d_point2 <= 21) or (p_point > 21) then
        #ディーラーが優勢
        #スタンド
        print <<-EOF
          <p>スタンドしました</p>
          <p>手札:#{session["dealer"]}</p>
        EOF
        if d_point != d_point2 then
          puts "<p>得点:#{d_point}or#{d_point2}<p>";
        else
          puts "<p>得点:#{d_point}<p>";
        end
      elsif p_point > d_point2 or d_point > 21 then
        #プレイヤーが優勢
        #ヒット
        num = rand(deck.length);
        draw = deck[num+1].to_i.modulo(13) + 1;
        deck.delete_at(num+1);
        puts "<p>ドローカード:#{draw}</p>";
        dealer.push(draw.to_s);
        q = 0;
        if draw.to_i > 10 then
          p = 10;
        elsif draw.to_i == 1 then
          p = draw.to_i;
          q = 10;
        else
          p = draw.to_i;
        end
        d_point = d_point + p;
        d_point2 = d_point2 + p + q;
        session["dealer"] = dealer;
        puts "<p>手札:#{session["dealer"]}</p>";
        if d_point != d_point2 then
          puts "<p>得点:#{d_point}or#{d_point2}<p>";
        else
          puts "<p>得点:#{d_point}<p>";
        end

        if d_point > 21 then
          puts "<h3>バスト</h3>"
        end
      else 
        #引き分け
        if d_point < 17 then 
          #ヒット
          num = rand(deck.length);
          draw = deck[num+1].to_i.modulo(13) + 1;
          deck.delete_at(num+1);
          puts "<p>ドローカード:#{draw}</p>";
          dealer.push(draw.to_s);
          q = 0;
          if draw.to_i > 10 then
            p = 10;
          elsif draw.to_i == 1 then
            p = draw.to_i;
            q = 10;
          else
            p = draw.to_i;
          end
          d_point = d_point + p;
          d_point2 = d_point2 + p + q;
          session["dealer"] = dealer;
          puts "<p>手札:#{session["dealer"]}</p>";
          if d_point != d_point2 then
            puts "<p>得点:#{d_point}or#{d_point2}<p>";
          else
            puts "<p>得点:#{d_point}<p>";
          end

          if d_point > 21 then
            puts "<h3>バスト</h3>"
          end
        else
          #スタンド
          print <<-EOF
            <p>スタンドしました</p>
            <p>手札:#{session["dealer"]}</p>
          EOF
          if d_point != d_point2 then
            puts "<p>得点:#{d_point}or#{d_point2}<p>";
          else
            puts "<p>得点:#{d_point}<p>";
          end
        end
      end
    end
    session["deck"] = deck.dup;

    if p_point != p_point2 and p_point <= 21 then
      #プレイヤーのAが有効
      if (p_point2 < d_point and d_point <= 21) or (p_point2 < d_point2 and d_point2 <= 21) then
        #ディーラーの勝ち
        game_over = 1;
      elsif p_point2 > d_point2 or d_point > 21 then
        #プレイヤーの勝ち
        game_over = 2;
      else 
        #引き分け
        game_over = 3;
      end
    else 
      #プレイヤーがAなしor無効
      if (p_point < d_point and d_point <= 21) or (p_point < d_point2 and d_point2 <= 21) or (p_point > 21) then
        #ディーラーの勝ち
        game_over = 1;
      elsif p_point > d_point2 or d_point > 21 then
        #プレイヤーの勝ち
        game_over = 2;
      else 
        #引き分け
        game_over = 3;
      end
    end
  end
end
session.close;


case game_over
when 0 then 
  print <<-EOF
    <hr>
    <a href="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/deal.rb">次へ</a>
    </body>
    </html>
  EOF
when 1 then
  #ディーラーの勝ち
  print <<-EOF
    <hr>
    <form action="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/result.rb" method="post">
    <p><input type="submit" name="dealer_win" value="ゲーム終了"></p>
    </form>
    </body>
    </html>
  EOF
when 2 then
  #プレイヤーの勝ち
  print <<-EOF
    <hr>
    <form action="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/result.rb" method="post">
    <p><input type="submit" name="player_win" value="ゲーム終了"></p>
    </form>
    </body>
    </html>
  EOF
when 3 then
  #引き分け
  print <<-EOF
    <hr>
    <form action="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/result.rb" method="post">
    <p><input type="submit" name="draw" value="ゲーム終了"></p>
    </form>
    </body>
    </html>
  EOF
end
