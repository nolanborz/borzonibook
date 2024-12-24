class UserMailer < ApplicationMailer
  default from: "notifications@example.com"

  def welcome_email
    @user = params[:user]
    @url = new_user_session_url
    mail(to: @user.email, subject: "Benvenuti su BorzoniBook!")
  end
end
