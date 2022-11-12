module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start)/ 60)/60.0) )
  end
  
  # 対応する曜日のcssクラスを割り当てる
  def set_color_of_day_of_week(day_num)
    case $days_of_the_week[day_num]
    when "土" then
      "sat_day"
    when "日" then
      "sun_day"
    else
      "week_day"
    end
  end
  
  # 時間表示を15分単位にする
  def calc_round_time(t)
    rounded_t = Time.local(t.year, t.month, t.day, t.hour, t.min/15*15)
    return rounded_t
  end
  
  # 勤怠変更申請中の日付を取得
  def get_attendance_chg_date(user_id, instructor)
    attendances = Attendance.where(user_id: user_id, approval_status: "申請中", instructor: instructor)
    return attendances
  end

end
