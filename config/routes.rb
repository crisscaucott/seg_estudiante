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
  post '/admini/estados_desercion/new', to: 'super_user#new_estado_desercion', as: 'new_estados_desercion'
  post '/admini/estados_desercion/update', to: 'super_user#update_estado_desercion', as: 'update_estado_desercion'
  # You can have the root of your site routed with "root"
  # root 'main#index'

  get '/carga_masiva', to: 'mass_load#index', as: 'mass_load'
  
  get '/carga_masiva/notas/subir', to: 'mass_load#notas', as: 'mass_load_notas'
  get '/carga_masiva/notas/ver', to: 'mass_load#get_notas', as: 'mass_load_get_notas'
  post '/carga_masiva/notas/filtering', to: 'mass_load#get_notas_filtering', as: 'filtering_notas'

  get '/carga_masiva/asistencia/subir', to: 'mass_load#asistencia', as: 'mass_load_asistencia'
  get '/carga_masiva/asistencia/ver', to: 'mass_load#get_asistencia', as: 'mass_load_get_asistencia'
  post '/carga_masiva/asistencia/asistencia_detalle', to: 'mass_load#get_asistencia_detail', as: 'mass_load_asistencia_detail'
  post '/carga_masiva/asistencia/filtering', to: 'mass_load#get_asistencia_filtering', as: 'filtering_asistencia'

  get '/carga_masiva/alumnos/subir', to: 'mass_load#alumnos', as: 'mass_load_alumnos'
  get '/carga_masiva/alumnos/ver', to: 'mass_load#get_alumnos', as: 'mass_load_get_alumnos'

  
  post '/carga_masiva/notas/upload_xls', to: 'mass_load#uploadXls', as: 'upload_xls'
  post '/carga_masiva/notas/upload_assis', to: 'mass_load#uploadAssistance', as: 'upload_assis'
  get '/reportes', to: 'main#reportes', as: 'reportes'
  get '/observaciones', to: 'main#observaciones', as: 'observaciones'
  get '/caracteristicas', to: 'main#caracteristicas', as: 'caracteristicas'
end
