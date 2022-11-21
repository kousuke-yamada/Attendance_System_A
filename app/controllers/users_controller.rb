class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :confirm_attendance]
  before_action :logged_in_user, only: [:index,:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: :show
  before_action :set_one_month, only: [:show, :confirm_attendance]
  before_action :set_monthly_attendance, only: :show

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count

    # １ヶ月分の勤怠申請件数の取得
    @one_month_attendance_sum = User.joins(:monthly_attendances).where(monthly_attendances: {approval_status: "申請中", instructor: @user.name}).count

    # 勤怠変更申請件数の取得
    @attendance_chg_req_sum = User.joins(:attendances).where(attendances: {approval_status: "申請中", instructor: @user.name}).count

    # 残業申請の件数取得
    @overtime_attendance_sum = User.joins(:attendances).where(attendances: {overtime_approval_status: "申請中", overtime_instructor: @user.name}).count
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user  # 保存成功後、ログインします。
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def search
    if params[:name].present?
      @users = User.where('name LIKE ?', "%#{params[:name]}%").page(params[:page]).per_page(20)
    else
      @users = User.paginate(page: params[:page])
    end
   
  end

  def csv_import
    if params[:file].present?
      error = User.import(params[:file])
      
      # インポート失敗時の処理
      if error.presence
        flash[:danger] = "csvインポート失敗しました。#{error}"
      else
        flash[:success] = "csvインポート成功しました。"
      end
    else
      # ファイル未選択
      flash[:danger] = "csvファイルを選択してください。"
    end

    redirect_to users_url
  end

  def attendance_at_work
    @users = User.joins(:attendances).where(attendances: {worked_on: Date.today, finished_at: nil}).where.not(attendances: {started_at: nil})
  end

  def confirm_attendance
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :basic_time, :work_time, :work_end_time, :password, :password_confirmaiton)
    end
    
    def basic_info_params
      params.require(:user).permit(:department,:basic_time, :work_time)
    end
end
