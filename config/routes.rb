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
      get 'attendances/disp_log'
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
