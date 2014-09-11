require 'rack'
require 'typhoeus'
require 'json'
require 'ap'
require 'sqlite3'
require 'date'
require 'erubis'
require_relative 'blog'


class BlogApp
    def initialize()
        @blogDb = Blog::BlogDb.new
        @posts = @blogDb.select_all_post
    end

	def call(env)

        request = Rack::Request.new(env)
        response = Rack::Response.new
        puts "path_info = "+request.path_info

        case request.path_info
        when '/', "/index"
            response.write render("post/index", {filter: request.GET['filter'], posts: @posts})

        when '/show'
            index = request.GET['index'].to_i
            response.write render("post/show", {index: index, post: @posts[index]})

        when '/new'
            response.write render("post/new")

        when '/create'
            add_post(request)
            response.redirect '/index'

        when '/edit'
            index = request.GET['index'].to_i
            response.write render("post/edit", {index: index, post: @posts[index]})

        when '/update'
            update_post(request)
            response.redirect '/'

        when '/destroy'
            delete_post(request)
            response.redirect '/index'

        when '/comment/new'
            index = request.GET['index'].to_i
            response.write render("comment/new", {index: index, post: @posts[index]})

        when '/comment/create'
            add_comment(request)
            response.redirect '/index'
        end
        
        response.finish

	end

    def add_post(request)  
        @posts.unshift @blogDb.create_post(
                                request.POST['title'], 
                                request.POST['content'], 
                                request.POST['author']
                                )
    end

    def add_comment(request)
        post = @posts[request.POST['index'].to_i]

        post.add_comment @blogDb.create_comment(
                                        post.id, 
                                        request.POST['comment'], 
                                        request.POST['author']
                                        )
    end

    def delete_post(request)
        index = request.GET['index'].to_i
        @blogDb.delete_post(@posts[index].id)
        @posts.delete_at(index)
    end

    def update_post(request)
        index = request.POST['index'].to_i
        post = @posts[index]
        post.title = request.POST['title']
        post.content = request.POST['content']
        post.author = request.POST['author']
        @blogDb.update_post(post)
        
    end

    def render(name, locals={})
        file = File.read("views/"+name+".erb")
        Erubis::Eruby.new(file).result(locals)
    end

end

# Rack::Handler::WEBrick.run(BlogApp.new)

