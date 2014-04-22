Rails.application.routes.draw do
  root 'api#index', default: { format: :json }

  scope only: [ :index, :update, :destroy ], default: { format: :json } do
    resources :users do
      get ':ids' => 'users#index', on: :collection, as: :some

      resources :articles do
        get ':ids' => 'articles#index', on: :collection, as: :some
      end
    end

    resources :articles, only: [ :index ] do
      get ':ids' => 'articles#index', on: :collection, as: :some

      resources :replies, only: [ :index, :update, :destroy ] do
        get ':ids' => 'replies#index', on: :collection, as: :some
      end
    end
  end
end
