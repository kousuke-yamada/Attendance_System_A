class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :disp_log, :attendance_chg_req, :apply_one_month_attendance, :one_month_attendance, :overtime_req, :show_overtime_req]
  before_action :set_user_by_user_id, only: :update
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :disp_log, :apply_one_month_attendance]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直して下さい。"

  APPROVAL_STS_NON = "なし"
  APPROVAL_STS_APL = "申請中"
  APPROVAL_STS_OK  = "承認"
  APPROVAL_STS_NG  = "否認"
  
  # 出勤・退勤登録ボタン押下時の処理
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
  
  # 勤怠編集ページの表示
  def edit_one_month
  end
  
  # 勤怠編集ページの更新ボタン押下時の処理
  def update_one_month
    error_flag = false
    no_inst_flag  = false
    
    ActiveRecord::Base.transaction do  # トランザクションを開始します。
      attendances_params.each do |id, item|
        if (item[:started_at].blank?   && item[:finished_at].present? ) || 
           (item[:started_at].present? && item[:finished_at].blank? )
           error_flag = true
           raise ActiveRecord::Rollback
        end 
        
        # 出勤時間、退勤時間の指定あり？
        if(item[:started_at].present? && item[:finished_at].present? ) 

          attendance = Attendance.find(id)  
          
          ######## デバックでデータ登録する時に使う用 ##########
          # attendance.update_attributes!(item)
          ################################################
                    
          # 変更前の出社時刻
          bfr_str_time = attendance.started_at.blank? ? nil : attendance.started_at.to_time
          # 変更前の退社時刻
          bfr_fin_time = attendance.finished_at.blank? ? nil : attendance.finished_at.to_time
          
          if ( bfr_str_time != item[:started_at].to_time ) ||
             ( bfr_fin_time != item[:finished_at].to_time )

            # 指示者確認印が設定されている場合のみ、変更有効
            if item[:instructor].present?

              # 変更したい出社時間
              attendance.chg_started_at = item[:started_at]
              # 変更したい退社時間
              attendance.chg_finished_at = item[:finished_at]
              # 備考
              attendance.note = item[:note]
              # 指示者
              attendance.instructor = item[:instructor]
              # 承認ステータス
              attendance.approval_status = APPROVAL_STS_APL
              
              attendance.save!
              # attendance.update_attributes!(item)
            else              
              # 指示者の指定なし
              no_inst_flag = true
              raise ActiveRecord::Rollback  
            end
          end
        end
      end
    end
    
    if error_flag 
      flash[:danger] = "出社時間、または退社時間どちらか片方のみの更新は出来ません。更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])  
    elsif no_inst_flag
      flash[:danger] = "勤怠変更の申請には指示者を指定して下さい。更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    else
      flash[:success] = "勤怠変更を申請しました。"
      redirect_to user_url(date: params[:date])
    end    
    
    rescue ActiveRecord::RecordInvalid  # トランザクションによるエラーの分岐です。
      flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 勤怠修正ログ(承認済)の表示
  def disp_log    
  end

  # 勤怠変更申請の内容表示
  def attendance_chg_req
    @applicants = User.joins(:attendances).where(attendances: {approval_status: "申請中", instructor: @user.name}).distinct    
  end

  # 勤怠変更申請の承認・否認処理
  def update_attendance_chg_req
    # 承認情報更新フラグ
    apply_flg = false

    ActiveRecord::Base.transaction do  # トランザクションを開始します。
      # 勤怠変更申請の承認処理
      attendances_application_params.each do |id, item|
        # checkboxにチェックあり？
        if item[:chg_permission] == "1"

          attendance = Attendance.find(id)

          case item[:approval_status]
          when APPROVAL_STS_OK    # 承認
            # 初回の申請承認の場合、初期の出社時間、退社時間を記録
            unless attendance.chg_permission
              attendance.first_started_at  = attendance.started_at    # 変更前 出社時間
              attendance.first_finished_at = attendance.finished_at   # 変更前 退社時間
            end
            # 変更申請中となっていた勤怠情報を本データとして設定する
            attendance.started_at  = attendance.chg_started_at        # 変更後 出社時間
            attendance.finished_at = attendance.chg_finished_at       # 変更後 退社時間
            attendance.chg_started_at  = nil
            attendance.chg_finished_at = nil
            attendance.approval_status = APPROVAL_STS_OK
            attendance.approval_date = Time.now
            attendance.chg_permission = true
            apply_flg = true

          when APPROVAL_STS_NG, APPROVAL_STS_NON    # 否認, なし
            attendance.chg_started_at  = nil
            attendance.chg_finished_at = nil
            attendance.approval_status = item[:approval_status]
            apply_flg = true

          else
            # 何もしない
          end
          
          # DBへ更新情報を記録
          attendance.save!
        end
      end
    
    end

    if apply_flg
      flash[:success] = "勤怠変更申請について、指示者確認情報を更新しました。"
    end
    redirect_to user_url(date: params[:date])

    rescue ActiveRecord::RecordInvalid  # トランザクションによるエラーの分岐です。
      flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  # １ヶ月分の勤怠申請ボタン押下時の処理
  def apply_one_month_attendance
    month = one_month_attendances_params[:monthly_attendances][:month]
    year = one_month_attendances_params[:monthly_attendances][:year]
    user_id = one_month_attendances_params[:monthly_attendances][:user_id]
    
    @monthly_attendance = MonthlyAttendance.find_by(month: month ,year: year, user_id: user_id)

    if @monthly_attendance
      # 申請先の所属長
      @monthly_attendance.instructor = one_month_attendances_params[:monthly_attendances][:instructor]
      # 申請ステータス
      @monthly_attendance.approval_status = APPROVAL_STS_APL
      # DBへ更新情報を記録
      @monthly_attendance.save!

      flash[:success] = "１ヶ月分の勤怠を申請しました"
    else
      flash[:danger] = "１ヶ月分の勤怠申請に失敗しました。"        
    end

    redirect_to user_url(@user, date: @first_day)
  end

  # １ヶ月分の勤怠申請の内容表示
  def one_month_attendance
    @applicants = User.joins(:monthly_attendances).where(monthly_attendances: {approval_status: "申請中", instructor: @user.name}).distinct
  end

  # １ヶ月分の勤怠申請の承認・否認処理
  def update_one_month_attendance
    # 承認情報更新フラグ
    apply_flg = false
    　
    ActiveRecord::Base.transaction do  # トランザクションを開始します。
      # 勤怠変更申請の承認処理
      one_month_attendances_application_params.each do |id, item|
        # checkboxにチェックあり？
        if item[:chg_permission] == "1"

          monthly_attendance = MonthlyAttendance.find(id)

          case item[:approval_status]
          when APPROVAL_STS_OK    # 承認
            monthly_attendance.approval_status = APPROVAL_STS_OK  
            monthly_attendance.chg_permission = true
            apply_flg = true  
            
          when APPROVAL_STS_NG, APPROVAL_STS_NON    # 否認, なし
            monthly_attendance.approval_status = item[:approval_status]
            monthly_attendance.chg_permission = true
            apply_flg = true

          else
            # 何もしない
          end
          
          # DBへ更新情報を記録
          monthly_attendance.save!
        end
      end    
    end

    if apply_flg
      flash[:success] = "１ヶ月分の勤怠申請について、指示者確認情報を更新しました。"
    end
    redirect_to user_url(date: params[:date])

    rescue ActiveRecord::RecordInvalid  # トランザクションによるエラーの分岐です。
      flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
      redirect_to user_url(date: params[:date])
   
  end

  # 残業申請フォームの表示
  def overtime_req
    @attendance = Attendance.find(params[:date_id])
  end

  # 残業申請フォームの内容送信時の処理
  def update_overtime_req
    @attendance = Attendance.find(params[:date_id])

    if @attendance.update_attributes(overtime_attendances_params)
      flash[:info] = "残業申請を行いました。"
    else
      flash[:danger] = "残業申請に失敗しました。再度、申請して下さい。"
    end
    redirect_to user_url(date: params[:date])
  end

  # 残業申請の内容表示
  def show_overtime_req
    @applicants = User.joins(:attendances).where(attendances: {overtime_approval_status: "申請中", overtime_instructor: @user.name}).distinct
  end

  # 残業申請の承認処理
  def apply_overtime_req
    # 承認情報更新フラグ
    apply_flg = false
    
    ActiveRecord::Base.transaction do   # トランザクションを開始します。
      # 残業申請の承認処理
      overtime_attendances_application_params.each do |id, item|
        #　checkboxにチェックあり？
        if item[:overtime_chg_permission] == "1"

          overtime_attendance = Attendance.find(id)

          case item[:overtime_approval_status]
          when APPROVAL_STS_OK    # 承認
            overtime_attendance.overtime_approval_status = APPROVAL_STS_OK
            overtime_attendance.overtime_chg_permission = true
            apply_flg = true  

          when APPROVAL_STS_NG, APPROVAL_STS_NON    # 否認、なし
            overtime_attendance.overtime_approval_status = item[:overtime_approval_status]
            overtime_attendance.overtime_chg_permission = true
            apply_flg = true

          else
            # 何もしない
          end

          # DBへ更新情報を記録
          overtime_attendance.save!
        end
      end  
    end

    if apply_flg
      flash[:success] = "残業申請について、指示者確認情報を更新しました。"
    end
    redirect_to user_url(date: params[:date])

    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効なデータがあったため、更新をキャンセルしました。"
      redirect_to user_url(date: params[:date])
  end

  private
    # １ヶ月分の勤怠情報を扱います
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :instructor])[:attendances]
    end

    # 勤怠申請変更の情報を扱います
    def attendances_application_params
      params.require(:user).permit(attendances: [:approval_status, :chg_permission, :user_id])[:attendances]
    end

    # １ヶ月分の勤怠承認情報（申請)を扱います
    def one_month_attendances_params
      params.require(:user).permit(monthly_attendances: [:month, :year, :instructor, :user_id])
    end

    # １ヶ月分の勤怠承認情報（承認）を扱います
    def one_month_attendances_application_params
      params.require(:user).permit(monthly_attendances: [:approval_status, :chg_permission, :user_id])[:monthly_attendances]
    end

    # 残業申請の申請内容（申請）を扱います
    def overtime_attendances_params
      params.require(:attendance).permit(:overtime_at, :overtime_content, :overtime_instructor, :overtime_approval_status)
    end

    # 残業申請の申請内容（承認）を扱います
    def overtime_attendances_application_params
      params.require(:user).permit(attendances: [:overtime_approval_status, :overtime_chg_permission, :user_id])[:attendances]
    end
end
