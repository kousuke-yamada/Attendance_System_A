class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :disp_log]
  before_action :set_user_by_user_id, only: :update
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :disp_log]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直して下さい。"
  
  def update
    @attendance = Attendance.find(params[:id])
    
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます!"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    error_flag = false
    
    ActiveRecord::Base.transaction do  # トランザクションを開始します。
      attendances_params.each do |id, item|
        if (item[:started_at].blank?   && item[:finished_at].present? ) || 
           (item[:started_at].present? && item[:finished_at].blank? )
           error_flag = true
           raise ActiveRecord::Rollback
        end 
        
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    
    unless error_flag 
      flash[:success] = "１ヶ月分の勤怠情報を更新しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "出社時間、または退社時間どちらか片方のみの更新は出来ません。更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
    
    rescue ActiveRecord::RecordInvalid  # トランザクションによるエラーの分岐です。
      flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def disp_log
    
  end

  private
    # １ヶ月分の勤怠情報を扱います
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
end
