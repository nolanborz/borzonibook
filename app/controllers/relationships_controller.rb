# app/controllers/relationships_controller.rb
class RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])  # Changed this line
    current_user.follow(@user)
    redirect_back(fallback_location: root_path)
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Unable to find user"
    redirect_back(fallback_location: root_path)
  end

  def destroy
    relationship = Relationship.find(params[:id])
    @user = relationship.followed
    current_user.unfollow(@user)
    redirect_back(fallback_location: root_path)
  end
end
