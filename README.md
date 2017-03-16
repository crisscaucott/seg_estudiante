# seg_estudiante
Aplicación web de seguimiento al estudiante para la Facultad de Ingeniería de la Universidad Central de Chile.

# ANTES DE INICIAR LA APLICACION...

# Llenar la tabla de permisos de usuario ('Decano', 'Director', 'Tutor', 'Usuario normal')
rake 'user:fill_permission_table'

# Crear el usuario inicial (tipo 'Decano'). Ayuda a poder usar la aplicacion.
rake 'user:create_super_user'

# Crear las escuelas
rake 'escuelas:fill_escuelas'

# Crear los estados de desercion iniciales
rake 'desercion:fill_deserciones'

# Crear los motivos de desercion
rake 'desercion:fill_motivos_desercion'

# Crear los destinos de desercion
rake 'desercion:fill_destinos'

# Crear las opciones de frecuencias de alertas
rake 'alertas:fill_frec_alertas'