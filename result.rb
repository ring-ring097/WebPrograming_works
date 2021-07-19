#!/usr/bin/env ruby
# encoding: utf-8
require "cgi"
require "cgi/session"

cgi = CGI.new;
print cgi.header("type" => "text/html", "charset" => "utf-8");

session = CGI::Session.new(cgi);

session.delete;
session.close;

print <<-EOF
  <html>
  <body>
  <h1>BRACK JACK</h1>
EOF

if !cgi["dealer_win"].empty? then
  print <<-EOF
    <h2>YOU LOSE</h2>
    <a href="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/deal.rb">もう1回</a>
    </body>
    </html>
  EOF
elsif !cgi["player_win"].empty? then
  print <<-EOF
    <h2>YOU WIN!</h2>
    <a href="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/deal.rb">もう1回</a>
    </body>
    </html>
  EOF
else
  print <<-EOF
    <h2>DRAW</h2>
    <a href="http://cgi.u.tsukuba.ac.jp/~s1911419/wp/deal.rb">もう1回</a>
    </body>
    </html>
  EOF
end


