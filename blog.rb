module Blog

class Post

	attr_reader :id, :date
	attr_accessor :comments, :title, :content, :author

	def initialize(hash)
		@id = hash["id"]
		@title = hash["title"]
		@content = hash["content"]
		@author = hash["author"]
		@date = DateTime.iso8601(hash["date"])
		@comments = []
	end

	def include?(filter)
		return true if (filter.nil? || filter.empty?)
		@title.include?(filter) || @content.include?(filter) || @author.include?(filter)
	end

	def add_comment(comment)
		@comments << comment
	end

	def pretty_date
		@date.strftime("%B %d, %Y at%l:%M%p") if @date != nil
	end

end

class Comment
	attr_reader :content, :author

	def initialize(hash)
		@content = hash["content"]
		@author = hash["author"]
	end
end

class BlogDb

	SQL_SELECT_ALL = "SELECT * FROM post;"
	SQL_SELECT_BY_ID = "SELECT * FROM post where ID = ?;"
	SQL_INSERT_POST = "INSERT INTO post (title, content, author, date) VALUES (?, ?, ?, ?);"
	SQL_INSERT_COMMENT = "INSERT INTO comment (post_id, content, author) VALUES (?, ?, ?);"
	SQL_SELECT_COMMENTS = "SELECT * FROM comment WHERE post_id = ?;"
	SQL_DELETE_POST = "DELETE FROM post WHERE id = ?;"
	SQL_DELETE_COMMENTS = "DELETE FROM comment WHERE post_id = ?;"
	SQL_UPDATE_POST = "UPDATE post SET title =?, content=? , author= ? WHERE id =?;"
	

	def initialize()
		@db = SQLite3::Database.new "data/blog.db"
		@db.execute 'PRAGMA foreign_keys = true;'
        @db.results_as_hash = true
	end

	def initDbTest(name)
		if File.exist? name
            File.delete name
        end
		@db = SQLite3::Database.new name
        @db.execute_batch File.read('../data/schema.sql')
		@db.execute 'PRAGMA foreign_keys = true;'
        @db.results_as_hash = true
	end

	def create_post(title, content, author)
		comment_date = DateTime.now
		@db.execute SQL_INSERT_POST, [title, content, author, comment_date.to_s]
		id = @db.last_insert_row_id
		row = @db.get_first_row(SQL_SELECT_BY_ID, [id])
		puts row
		Post.new(row)
	end

	def update_post(post)
		@db.execute SQL_UPDATE_POST, [post.title, post.content, post.author, post.id]
	end

	def select_all_post()
		posts = []
		result = @db.execute SQL_SELECT_ALL
		result.each do |row|
			post = Post.new(row)
			post.comments = select_comments(post.id)
			posts << post
		end
		posts.reverse
	end

	def select_comments(post_id)
		results = @db.execute SQL_SELECT_COMMENTS, [post_id]
		results.map do |row|
			Comment.new(row)
		end
	end

	def create_comment(post_id, content, author)
		@db.execute SQL_INSERT_COMMENT, [post_id, content, author]
		Comment.new({"author" => author, "content" =>content})
	end

	def delete_post(id)
		@db.execute SQL_DELETE_COMMENTS, [id]
		@db.execute SQL_DELETE_POST, [id]
	end

end

end