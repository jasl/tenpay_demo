TenpayDemo::Application.routes.draw do
  resources :orders do
    member do
      get 'notify'
      get 'callback'
      get 'pay'
    end
  end

  root 'home#index'
end
