# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( sign_up.js sign_in.css sign_in.js notas.js asistencia.js validar_rut.js estados_desercion.js estados_desercion.css mass_load.js ver_notas.js ver_asistencias.js update_estados_desercion.js update_usuarios.js estudiantes.js subir_estudiantes.js frec_alertas_config.js)
