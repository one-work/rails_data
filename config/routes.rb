Rails.application.routes.draw do
  namespace :datum, defaults: { business: 'datum' } do
    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      resources :data_lists, only: [] do
        resources :table_lists do
          collection do
            match :find, via: [:get, :post]
            match :new_import, via: [:get, :post]
            post :create_import
          end
          member do
            match :chart, via: [:get, :post]
          end
        end
      end
      resources :templates do
        resources :validations
        resources :template_items
        resources :exports do
          resources :export_items
        end
      end
    end
    namespace :panel, defaults: { namespace: 'panel' } do
      root 'home#index'
      resources :data_exports do
        collection do
          post :sync
        end
        member do
          put :update_publish
          patch :rebuild
        end
      end
      resources :data_imports do
        collection do
          post :sync
        end
        member do
          patch :rebuild
          get :template
        end
      end
      resources :data_lists, only: [] do
        resources :table_lists do
          collection do
            get :direct
            match :new_import, via: [:get, :post]
            post :create_import
          end
          member do
            match :chart, via: [:get, :post]
            get :row
            get :xlsx
            get :pdf, defaults: { format: 'pdf' }
            patch :run
            patch :migrate
          end
        end
      end
      resources :data_records do
        collection do
          get :add_item
          get :remove_item
        end
        member do
          patch :rebuild
        end
        resources :record_lists do
          collection do
            match :find, via: [:get, :post]
          end
          member do
            get :row
            patch :run
            get 'columns' => :edit_columns
            patch 'columns' => :update_columns
          end
        end
      end
    end
  end
end
