Rails.application.routes.draw do
  
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # 拠点情報
  resources :bases

  # ユーザー情報
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      # csvエクスポート
      get :csv_export, defaults: {format: 'csv'}

      # 勤怠修正ログ(承認済)
      get 'attendances/disp_log'
      post 'attendances/search_log'
      # 勤怠変更申請     
      get 'attendances/attendance_chg_req'
      patch 'attendances/update_attendance_chg_req'
      # 申請者の勤怠確認
      get 'confirm_attendance'
      # １ヶ月分の勤怠承認
      patch 'attendances/apply_one_month_attendance'
      get 'attendances/one_month_attendance'
      patch 'attendances/update_one_month_attendance'
      # 残業申請
      get 'attendances/overtime_req'
      patch 'attendances/update_overtime_req'
      get 'attendances/show_overtime_req'
      patch 'attendances/apply_overtime_req'
    end
    
    resources :attendances, only: :update
    
    collection do
      # user検索  
      get :search
      # csvインポート
      post :csv_import
      # 出勤中社員一覧
      get :attendance_at_work
    end
  end
end
