require 'sqlite3'

db = SQLite3::Database.new "blog.db"

table = db.execute <<-SQL
CREATE TABLE post (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  author TEXT,
  date TEXT
);
SQL

table = db.execute <<-SQL
CREATE TABLE comment (
  id INTEGER PRIMARY KEY,
  post_id INTEGER REFERENCES post(id),
  content NOT NULL,
  author TEXT
);
SQL