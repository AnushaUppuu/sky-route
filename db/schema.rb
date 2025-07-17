# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_16_171550) do
  execute "CREATE SCHEMA IF NOT EXISTS auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "flights", force: :cascade do |t|
    t.string "airlines"
    t.string "flight_number"
    t.bigint "source_city_id", null: false
    t.bigint "destination_city_id", null: false
    t.decimal "economy_base_price"
    t.decimal "first_class_base_price"
    t.decimal "second_class_base_price"
    t.integer "economy_total_seats"
    t.integer "first_class_total_seats"
    t.integer "second_class_total_seats"
    t.date "departure_date"
    t.time "departure_time"
    t.date "arrival_date"
    t.time "arrival_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "flights", "cities", column: "destination_city_id"
  add_foreign_key "flights", "cities", column: "source_city_id"
end
