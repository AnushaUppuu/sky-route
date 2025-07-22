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

ActiveRecord::Schema[8.0].define(version: 2025_07_22_091439) do
  create_schema "auth"
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

  create_table "airlines", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "airports", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flight_classes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flight_custom_dates", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.date "custom_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_flight_custom_dates_on_flight_id"
  end

  create_table "flight_schedules", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.time "departure_time"
    t.time "arrival_time"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_flight_schedules_on_flight_id"
  end

  create_table "flight_seats", force: :cascade do |t|
    t.bigint "flight_schedule_id", null: false
    t.bigint "flight_class_id", null: false
    t.integer "total_seats"
    t.integer "available_seats"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_class_id"], name: "index_flight_seats_on_flight_class_id"
    t.index ["flight_schedule_id"], name: "index_flight_seats_on_flight_schedule_id"
  end

  create_table "flight_special_dates", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.date "special_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_flight_special_dates_on_flight_id"
  end

  create_table "flight_weekdays", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.string "day_of_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_flight_weekdays_on_flight_id"
  end

  create_table "flights", force: :cascade do |t|
    t.bigint "airline_id", null: false
    t.string "flight_number"
    t.bigint "source_airport_id", null: false
    t.bigint "destination_airport_id", null: false
    t.bigint "recurrence_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["airline_id"], name: "index_flights_on_airline_id"
    t.index ["destination_airport_id"], name: "index_flights_on_destination_airport_id"
    t.index ["recurrence_id"], name: "index_flights_on_recurrence_id"
    t.index ["source_airport_id"], name: "index_flights_on_source_airport_id"
  end

  create_table "recurrences", force: :cascade do |t|
    t.string "recurrence_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "flight_custom_dates", "flights"
  add_foreign_key "flight_schedules", "flights"
  add_foreign_key "flight_seats", "flight_classes"
  add_foreign_key "flight_seats", "flight_schedules"
  add_foreign_key "flight_special_dates", "flights"
  add_foreign_key "flight_weekdays", "flights"
  add_foreign_key "flights", "airlines"
  add_foreign_key "flights", "airports", column: "destination_airport_id"
  add_foreign_key "flights", "airports", column: "source_airport_id"
  add_foreign_key "flights", "recurrences"
end
