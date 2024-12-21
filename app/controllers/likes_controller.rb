class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post

  def create
    @post.likes.create(user: current_user) unless @post.liked_by?(current_user)
    redirect_back(fallback_location: root_path)
  end

  def destroy
    @post.likes.where(user: current_user).destroy_all
    redirect_back(fallback_location: root_path)
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
