# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161213233902) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerta", force: :cascade do |t|
    t.integer  "usuario_id",                        null: false
    t.string   "tipo_alerta",                       null: false
    t.datetime "fecha_envio",                       null: false
    t.string   "mensaje"
    t.string   "estado",      default: "Pendiente", null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "asignatura", force: :cascade do |t|
    t.string   "nombre",        null: false
    t.string   "codigo",        null: false
    t.integer  "creditos",      null: false
    t.datetime "fecha_borrado"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "asignatura_carrera", force: :cascade do |t|
    t.integer "carrera_id"
    t.integer "asignatura_id"
  end

  create_table "asistencia", force: :cascade do |t|
    t.integer  "asignatura_id",    null: false
    t.integer  "estudiante_id",    null: false
    t.datetime "fecha_asistida",   null: false
    t.string   "valor_asistencia"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "calificacion", force: :cascade do |t|
    t.integer  "estudiante_id",                               null: false
    t.integer  "asignatura_id",                               null: false
    t.decimal  "valor_calificacion",  precision: 5, scale: 2, null: false
    t.string   "nombre_calificacion",                         null: false
    t.integer  "ponderacion",                                 null: false
    t.datetime "periodo_academico",                           null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "carrera", force: :cascade do |t|
    t.integer  "duracion_formal",   null: false
    t.string   "nombre",            null: false
    t.string   "codigo",            null: false
    t.datetime "fecha_eliminacion"
    t.string   "plan",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "escuela_id",        null: false
  end

  create_table "destinos", force: :cascade do |t|
    t.string "nombre", null: false
  end

  create_table "escuela", force: :cascade do |t|
    t.string   "nombre",      null: false
    t.string   "codigo"
    t.integer  "director_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "estado_desercion", force: :cascade do |t|
    t.string  "nombre_estado",                 null: false
    t.boolean "notificar",     default: false
    t.boolean "riesgoso",      default: false, null: false
  end

  create_table "estilos_aprendizaje", force: :cascade do |t|
    t.integer  "estudiante_id",    null: false
    t.integer  "honey_activo"
    t.integer  "honey_reflexivo"
    t.integer  "honey_teorico"
    t.integer  "honey_practico"
    t.integer  "vark_visual"
    t.integer  "vark_auditivo"
    t.integer  "vark_le"
    t.integer  "vark_kinestesico"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "estudiante", force: :cascade do |t|
    t.string   "nombre",              null: false
    t.string   "apellido",            null: false
    t.string   "rut",                 null: false
    t.integer  "carrera_id",          null: false
    t.integer  "estado_desercion_id", null: false
    t.datetime "fecha_eliminacion"
    t.datetime "fecha_ingreso",       null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "dv",                  null: false
  end

  create_table "ficha_estudiante", force: :cascade do |t|
    t.integer  "estudiante_id",       null: false
    t.integer  "tutor_id",            null: false
    t.integer  "estado_desercion_id", null: false
    t.integer  "motivo_desercion_id"
    t.integer  "destino_id"
    t.datetime "fecha_registro",      null: false
    t.text     "comentario"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "frec_alerta", force: :cascade do |t|
    t.integer "dias",    null: false
    t.string  "mensaje", null: false
  end

  create_table "log_carga_masiva", force: :cascade do |t|
    t.integer  "usuario_id",  null: false
    t.string   "tipo_carga",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "url_archivo", null: false
    t.json     "detalle"
  end

  create_table "motivo_desercion", force: :cascade do |t|
    t.string "nombre", null: false
  end

  create_table "reportes", force: :cascade do |t|
    t.string   "nombre_reporte",                 null: false
    t.string   "tipo_reporte",                   null: false
    t.integer  "usuario_id",                     null: false
    t.boolean  "descargado",     default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "tutor_estudiante", force: :cascade do |t|
    t.integer "usuario_id"
    t.integer "estudiante_id"
  end

  create_table "user_permissions", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "name",                                null: false
    t.string   "last_name",                           null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "id_permission",                       null: false
    t.string   "rut",                                 null: false
    t.datetime "deleted_at"
    t.integer  "frec_alerta_id"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["rut"], name: "index_users_on_rut", unique: true, using: :btree

  add_foreign_key "alerta", "users", column: "usuario_id"
  add_foreign_key "asistencia", "asignatura"
  add_foreign_key "asistencia", "estudiante"
  add_foreign_key "calificacion", "asignatura"
  add_foreign_key "calificacion", "estudiante"
  add_foreign_key "carrera", "escuela"
  add_foreign_key "escuela", "users", column: "director_id"
  add_foreign_key "estilos_aprendizaje", "estudiante"
  add_foreign_key "estudiante", "carrera"
  add_foreign_key "estudiante", "estado_desercion"
  add_foreign_key "ficha_estudiante", "estado_desercion"
  add_foreign_key "ficha_estudiante", "estudiante"
  add_foreign_key "ficha_estudiante", "users", column: "tutor_id"
  add_foreign_key "log_carga_masiva", "users", column: "usuario_id"
  add_foreign_key "reportes", "users", column: "usuario_id"
  add_foreign_key "users", "frec_alerta", column: "frec_alerta_id"
  add_foreign_key "users", "user_permissions", column: "id_permission"
end
