Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get "employees", to: "users#get_users"
  post "employees", to: "users#create_user"
  get "employees/:user_id", to: "users#get_user"
  put "employees/:user_id", to: "users#update_user"
  delete "employees/:user_id", to: "users#delete_user"

  get "timesheets", to: "timesheets#get_timesheets"
  post "timesheets/:user_id/clock_in", to: "timesheets#clock_in"
  post "timesheets/:user_id/clock_out", to: "timesheets#clock_out"
end
