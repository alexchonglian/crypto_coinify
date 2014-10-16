class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :set_locale

  def self.add_providers

  end

  def twitter
    omniauth = request.env['omniauth.auth']['info']
    unless (@auth = Authorization.find_from_hash(request.env['omniauth.auth']))
      omniauth['email'] = '@' +omniauth['nickname']
      user = User.find_or_create_twitter_oauth(omniauth)
      # user = current_user || (User.find_by_email(omniauth[:info][:email]) if omniauth[:info][:email])

      # Twitter doesn't provide any email addr, so let's use his twitter handle
      @auth = Authorization.create_from_hash(request.env['omniauth.auth'], user)

      # Fulfill rewards pending
      Api::KoinController.new.fulfill_rewards(nil, omniauth['nickname'])

    end
    flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Twitter")
    sign_in @auth.user, event: :authentication
    redirect_to(session[:return_to] || root_path)
    session[:return_to] = nil
  end
end
