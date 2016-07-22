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

ActiveRecord::Schema.define(version: 20160721233735) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string   "firstName"
    t.string   "middleName"
    t.string   "firstSurname"
    t.string   "secondSurname"
    t.float    "currentSalary"
    t.date     "birthDate"
    t.string   "personalId"
    t.string   "rif"
    t.string   "jobTittle"
    t.date     "admissionDate"
    t.string   "phone"
    t.string   "cellphone"
    t.text     "address"
    t.string   "email"
    t.string   "email2"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "gender"
    t.integer  "fk_user"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.string   "profilePicture"
    t.string   "status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end
