require 'koala'

module SessionHelper
  def signed_in?
    !!session['access_token']
  end

  def sign_in(access_token, user_data)
    session['access_token'] = access_token
    session['user_name'] = user_data["name"]
    session['user_id'] = user_data["id"]
  end

  def sign_out
    session.delete('oauth')
    session.delete('access_token')
    session.delete('user_name')
    session.delete('user_id')
  end
end
