class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :edit, :update ]
  before_action :ensure_correct_user, only: [ :edit, :update ]
  def index
    @users = User.where.not(id: current_user.id)
                 .includes(:followers, :following)
  end

  def edit
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    if params[:user][:password].present?
      # If changing password, use Devise's update_with_password
      if @user.update_with_password(user_params)
        bypass_sign_in(@user)  # Keep user signed in after password change
        redirect_to @user, notice: "Profile updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # If not changing password, use regular update with filtered params
      if @user.update(user_params_without_password)
        redirect_to profile_path, notice: "Profile updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
  private
  def user_params_without_password
    params.require(:user).permit(:username, :email, :bio)
  end
  def set_user
    @user = User.find(params[:id])
  end
  def ensure_correct_user
    unless @user == current_user
      redirect_to root_path, alert: "You're not authorized to edit this profile."
    end
  end
  def user_params
    params.require(:user).permit(
      :username,
      :email,
      :bio,
      :current_password,
      :password,
      :password_confirmation
    )
  end
end
