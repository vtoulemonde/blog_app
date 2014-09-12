require 'sqlite3'

module BlogModule

	SQL_CREATE_TABLE_POST<<-SQL
	CREATE TABLE post (
	  id INTEGER PRIMARY KEY,
	  title TEXT NOT NULL,
	  content TEXT,
	  author TEXT,
	  date TEXT
	);
	SQL

	SQL_CREATE_TABLE_COMMENT<<-SQL
	CREATE TABLE comment (
	  id INTEGER PRIMARY KEY,
	  post_id INTEGER REFERENCES post(id),
	  content NOT NULL,
	  author TEXT
	);
	SQL


	def createSchema(db)
		db.execute SQL_CREATE_TABLE_POST
		db.execute SQL_CREATE_TABLE_COMMENT
	end

end
dbBlog = SQLite3::Database.new "blog.db"
BlogModule.load_schema(dbBlog)