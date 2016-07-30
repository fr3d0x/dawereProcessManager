Rails.application.routes.draw do

  resources :gits, except: [:new, :edit]
  scope(:path => '/api') do
    resources :vdm_changes, except: [:new, :edit]
    resources :vdms, except: [:new, :edit] do
      collection do
        post :addVdm
        get :getVdmsBySubject
        get :getWholeVdm
      end
    end
    resources :classes_planifications, except: [:new, :edit] do
      collection do
        get :getClassPlan
      end
    end
    resources :subject_planifications do
      collection do
        get :getSubjectsPlanning
        get :getWholeSubjectPlanning
      end
    end
    resources :subjects, except: [:new, :edit] do
      collection do
        get :getSubjectByGrade
      end
    end
    resources :teachers, except: [:new, :edit]
    resources :users, except: [:new, :edit] do
      collection do
        post :login
        get :globalProgress
      end
    end
    resources :employees, except: [:new, :edit]
    resources :grades, except: [:new, :edit] do
      collection do
        get :getGradesWithSubjects
      end
    end
    resources :global_progresses, except: [:new, :edit]
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
