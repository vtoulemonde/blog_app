CREATE TABLE post (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  author TEXT,
  date TEXT
);

CREATE TABLE comment (
  id INTEGER PRIMARY KEY,
  post_id INTEGER REFERENCES post(id),
  content NOT NULL,
  author TEXT
);