module ApplicationHelper
  
  # ページごとにタイトルを返す
  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?
      base_title
    else
      page_name + " | " + full_title
    end
  end

  # 時間外時間を算出
  def calc_overtime(estimated_endtime, basetime)
    finish_t = estimated_endtime.hour + (estimated_endtime.min.to_f / 60)
    start_t = basetime.hour + (basetime.min.to_f / 60)

    if finish_t < start_t 
      overtime_t = finish_t + (24 - start_t)
    else
      overtime_t = finish_t - start_t
    end    
    
    return overtime_t
  end
end
