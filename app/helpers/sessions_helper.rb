module SessionsHelper
  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # セッションと@current_userを削除します
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 現在ログイン中のユーザーがいる場合にオブジェクトを返します。
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  
  # 現在ログイン中のユーザーがいればtrue,そうでなければfalseを返します。
  def logged_in?
    !current_user.nil?
  end
  
end
