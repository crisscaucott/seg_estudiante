Rails.application.routes.draw do
  devise_for :users, :controllers => {registrations: "my_devises/registrations", sessions: "my_devises/sessions"}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_scope :user do
    root to: "main#index"
  end

  get '/admini/', to: 'super_user#index', as: 'admini'
  get '/admini/nuevo_usuario', to: 'super_user#new_user', as: 'new_user'
  post '/admini/nuevo_usuario/new', to: 'super_user#createUser', as: 'new_user_new'
  get '/admini/estados_desercion', to: 'super_user#estados_desercion_index', as: 'estados_desercion'
  # You can have the root of your site routed with "root"
  # root 'main#index'

  get '/carga_masiva', to: 'mass_load#index', as: 'mass_load'
  get '/carga_masiva/notas', to: 'mass_load#notas', as: 'notas'
  get '/carga_masiva/asistencia', to: 'mass_load#asistencia', as: 'asistencia'
  get '/carga_masiva/alumnos', to: 'mass_load#alumnos', as: 'alumnos'
  post '/carga_masiva/notas/upload_xls', to: 'main#uploadXls', as: 'upload_xls'
  post '/carga_masiva/notas/upload_assis', to: 'mass_load#uploadAssistance', as: 'upload_assis'
  get '/reportes', to: 'main#reportes', as: 'reportes'
  get '/observaciones', to: 'main#observaciones', as: 'observaciones'
  get '/caracteristicas', to: 'main#caracteristicas', as: 'caracteristicas'
end
