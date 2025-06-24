OpenProject::Application.routes.draw do
    scope 'admin', as: 'admin' do
      resources :calculated_custom_fields do
        collection do
          post :preview
        end
      end
    end
  end