module ApplicationHelper
  def gravatar_for(user, size: 80)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=identicon"
    image_tag(gravatar_url, alt: user.email, class: "rounded-full")
  end
end
