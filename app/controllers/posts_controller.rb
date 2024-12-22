class PostsController < ApplicationController
  def index
    @show_followed = params[:filter] == "following"
    @posts = if @show_followed && current_user
      Post.where(user: [ current_user ] + current_user.following)
          .includes(:user, :comments)
          .order(created_at: :desc)
    else
      Post.includes(:user, :comments).order(created_at: :desc)
    end
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, notice: "Post created!"
    else
      @posts = Post.includes(:user).order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:content)
  end
end
