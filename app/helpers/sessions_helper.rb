module SessionsHelper
  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # 永続的セッションを記憶します(Userモデルを参照)
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 永続的セッションを破棄します
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # セッションと@current_userを削除します
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 現在ログイン中のユーザーがいる場合にオブジェクトを返します。
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # 渡されたユーザーがログイン済みのユーザーであればtrueを返します。
  def current_user?(user)
    user == current_user
  end
  
  # 現在ログイン中のユーザーがいればtrue,そうでなければfalseを返します。
  def logged_in?
    !current_user.nil?
  end
  
  # 記憶しているURL(またはデフォルトURL)にリダイレクトします。
  def redirect_back_or(default_url)
    redirect_to(session[:forwording_url] || default_url)
    session.delete(:forwording_url)
  end
  
  # アクセスしようとしたURLを記録します。
  def store_location
    session[:forwording_url] = request.original_url if request.get?
  end
end
