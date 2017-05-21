Rails.application.routes.draw do

  scope(:path => '/api') do
    resources :post_prod_dpt_assignments, except: [:new, :edit]
    resources :post_prod_dpts, except: [:new, :edit]
    root 'employees#index'
    resources :product_managements, except: [:new, :edit]
    resources :production_dpts, except: [:new, :edit]
    resources :vdm_changes, except: [:new, :edit] do
      collection do
        get :getVdmsChangesBySubject
      end
    end
    resources :vdms, except: [:new, :edit] do
      collection do
        post :addVdm
        get :getVdmsBySubject
        get :getWholeVdm
        post :updateVdm
        post :deleteVdm
        get :getDawereVdms
        post :approveVdm
        post :rejectVdm
        post :upload_edition_files
        post :upload_pre_production_files
        post :upload_design_files
        post :upload_production_files
        post :upload_post_production_files
        post :raw_material_upload
        get :resume_file
      end
    end
    resources :classes_planifications, except: [:new, :edit] do
      collection do
        get :getClassPlan
        post :deleteClassPlan
        post :saveCp
        post :editCp
        post :mergeCp
      end
    end
    resources :subject_planifications do
      collection do
        get :getSubjectsPlanning
        get :getWholeSubjectPlanning
        post :saveSubjectPlanning
      end
    end
    resources :subjects, except: [:new, :edit] do
      collection do
        get :getSubjectByGrade
        post :createSubject
        post :assignSubject
      end
    end
    resources :teachers, except: [:new, :edit]
    resources :users, except: [:new, :edit] do
      collection do
        post :login
        get :global_progress
        get :employee_progress
        post :generatePdf
      end
    end
    resources :employees, except: [:new, :edit]

    resources :grades, except: [:new, :edit] do
      collection do
        get :getGradesWithSubjects
      end
    end
    resources :cp_changes, except: [:new, :edit] do
      collection do
        get :getChangesBySubject
      end
    end
    resources :qa_analists, except: [:new, :edit]
    resources :qa_dpts, except: [:new, :edit]

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
