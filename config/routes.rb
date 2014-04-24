Rails.application.routes.draw do
  root 'api#index', default: { format: :json }

  get "uuids/:num" => "api#uuids", as: :uuids
  get "uuids"      => "api#uuids", as: :uuid

  scope only: [ :index, :update ], default: { format: :json } do
    resources :users do
      get    ':ids' => 'users#index',  on: :collection, as: :some
      delete ':id'  => 'users#update', on: :collection

      resources :articles do
        get    ':ids' => 'articles#index',  on: :collection, as: :some
        delete ':id'  => 'articles#update', on: :collection
      end
    end

    resources :articles, only: [ :index ] do
      get    ':ids' => 'articles#index',  on: :collection, as: :some
      delete ':id'  => 'articles#update', on: :collection

      resources :replies, only: [ :index, :update ] do
        get    ':ids' => 'replies#index',  on: :collection, as: :some
        delete ':id'  => 'replies#update', on: :collection
      end
    end
  end
end
