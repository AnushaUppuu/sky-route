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

ActiveRecord::Schema[8.0].define(version: 2025_07_24_061833) do
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
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_airlines_on_code", unique: true
  end

  create_table "airports", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_airports_on_code", unique: true
  end

  create_table "flight_classes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_flight_classes_on_name", unique: true
  end

  create_table "flight_custom_dates", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.date "custom_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id", "custom_date"], name: "index_flight_custom_dates_on_flight_and_date", unique: true
    t.index ["flight_id"], name: "index_flight_custom_dates_on_flight_id"
  end

  create_table "flight_schedules", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.time "departure_time", null: false
    t.time "arrival_time", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id", "departure_time", "arrival_time"], name: "index_flight_schedules_on_flight_and_times", unique: true
    t.index ["flight_id"], name: "index_flight_schedules_on_flight_id"
  end

  create_table "flight_seat_availabilities", force: :cascade do |t|
    t.bigint "flight_seat_id", null: false
    t.date "scheduled_date", null: false
    t.integer "available_seats", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_seat_id", "scheduled_date"], name: "index_flight_seat_availabilities_on_seat_and_date", unique: true
    t.index ["flight_seat_id"], name: "index_flight_seat_availabilities_on_flight_seat_id"
  end

  create_table "flight_seats", force: :cascade do |t|
    t.bigint "flight_schedule_id", null: false
    t.bigint "flight_class_id", null: false
    t.integer "total_seats", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_class_id"], name: "index_flight_seats_on_flight_class_id"
    t.index ["flight_schedule_id", "flight_class_id"], name: "index_flight_seats_on_schedule_and_class", unique: true
    t.index ["flight_schedule_id"], name: "index_flight_seats_on_flight_schedule_id"
  end

  create_table "flight_special_dates", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.date "special_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id", "special_date"], name: "index_flight_special_dates_on_flight_and_date", unique: true
    t.index ["flight_id"], name: "index_flight_special_dates_on_flight_id"
  end

  create_table "flight_weekdays", force: :cascade do |t|
    t.bigint "flight_id", null: false
    t.string "day_of_week", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id", "day_of_week"], name: "index_flight_weekdays_on_flight_and_day", unique: true
    t.index ["flight_id"], name: "index_flight_weekdays_on_flight_id"
  end

  create_table "flights", force: :cascade do |t|
    t.bigint "airline_id", null: false
    t.string "flight_number", null: false
    t.bigint "source_airport_id", null: false
    t.bigint "destination_airport_id", null: false
    t.bigint "recurrence_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["airline_id"], name: "index_flights_on_airline_id"
    t.index ["destination_airport_id"], name: "index_flights_on_destination_airport_id"
    t.index ["flight_number"], name: "index_flights_on_flight_number", unique: true
    t.index ["recurrence_id"], name: "index_flights_on_recurrence_id"
    t.index ["source_airport_id"], name: "index_flights_on_source_airport_id"
  end

  create_table "recurrences", force: :cascade do |t|
    t.string "recurrence_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recurrence_type"], name: "index_recurrences_on_recurrence_type", unique: true
  end

  add_foreign_key "flight_custom_dates", "flights"
  add_foreign_key "flight_schedules", "flights"
  add_foreign_key "flight_seat_availabilities", "flight_seats"
  add_foreign_key "flight_seats", "flight_classes"
  add_foreign_key "flight_seats", "flight_schedules"
  add_foreign_key "flight_special_dates", "flights"
  add_foreign_key "flight_weekdays", "flights"
  add_foreign_key "flights", "airlines"
  add_foreign_key "flights", "airports", column: "destination_airport_id"
  add_foreign_key "flights", "airports", column: "source_airport_id"
  add_foreign_key "flights", "recurrences"
end
