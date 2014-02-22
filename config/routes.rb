T4c::Application.routes.draw do

  root 'home#index'

  resources :users, :only => [:show, :update, :index] do
    get :login, on: :collection
  end
  resources :projects, :only => [:show, :index, :create] do
    resources :tips, :only => [:index]
    get :qrcode, on: :member
  end
  resources :tips, :only => [:index]
  resources :withdrawals, :only => [:index]

  devise_for :users,
    :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks"
    }
end
