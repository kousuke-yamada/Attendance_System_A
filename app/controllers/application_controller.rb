class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # beforeフィルター
  
  # paramsハッシュ(:id)からユーザーを取得します。
  def set_user
    begin
      @user = User.find(params[:id])
    rescue
      flash[:danger] = "不正なアクセスです。"
      redirect_to root_url
    end
  end
  
  # paramsハッシュ(:user_id)からユーザーを取得します。
  def set_user_by_user_id
    @user = User.find(params[:user_id])
  end
  
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    unless current_user?(@user)
      flash[:danger] = "不正なユーザーです。"
      redirect_to(root_url) 
    end
  end
  
  # システム管理権限所有かどうか判定します。
  def admin_user
    unless current_user.admin?
      flash[:danger] = "管理者権限がありません"
      redirect_to root_url
    end
  end
  
  # 管理権限者、または、現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "アクセス権限がありません"
      redirect_to(root_url)
    end
  end

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month 
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end

  def set_monthly_attendance
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    
    month = @first_day.month.to_s
    year  = @first_day.year.to_s
    @month_attendances = @user.monthly_attendances.where(month: month, year: year)
    
    unless @month_attendances.count > 0
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        @user.monthly_attendances.create!(month: month, year: year)
      end
      @month_attendances = @user.monthly_attendances.where(month: month, year: year)
    end

    rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
      redirect_to root_url
  end

end
