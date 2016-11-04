Rails.application.routes.draw do
  devise_for :users, :controllers => {registrations: "my_devises/registrations", sessions: "my_devises/sessions"}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_scope :user do
  	root to: "main#index"
  end

  # You can have the root of your site routed with "root"
  # root 'main#index'

  get '/notas', to: 'main#notas', as: 'notas'
  get '/reportes', to: 'main#reportes', as: 'reportes'
  get '/observaciones', to: 'main#observaciones', as: 'observaciones'
  get '/caracteristicas', to: 'main#caracteristicas', as: 'caracteristicas'
end
