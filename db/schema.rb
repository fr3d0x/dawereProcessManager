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

ActiveRecord::Schema.define(version: 20160728192223) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "classes_planifications", force: :cascade do |t|
    t.string   "meGeneralObjective"
    t.string   "meSpecificObjective"
    t.text     "meSpecificObjDesc"
    t.string   "topicName"
    t.string   "videos"
    t.integer  "subject_planification_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "classes_planifications", ["subject_planification_id"], name: "index_classes_planifications_on_subject_planification_id", using: :btree

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
  end

  create_table "grades", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "role"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "primary"
  end

  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

  create_table "subject_planifications", force: :cascade do |t|
    t.string   "status"
    t.integer  "teacher_id"
    t.integer  "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "subject_planifications", ["subject_id"], name: "index_subject_planifications_on_subject_id", using: :btree
  add_index "subject_planifications", ["teacher_id"], name: "index_subject_planifications_on_teacher_id", using: :btree
  add_index "subject_planifications", ["user_id"], name: "index_subject_planifications_on_user_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "name"
    t.text     "shortDescription"
    t.text     "longDescription"
    t.text     "firstPeriodDesc"
    t.text     "secondPeriodDesc"
    t.text     "thirdPeriodDesc"
    t.text     "goal"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "grade_id"
  end

  add_index "subjects", ["grade_id"], name: "index_subjects_on_grade_id", using: :btree

  create_table "teachers", force: :cascade do |t|
    t.text     "cvLong"
    t.text     "cvShort"
    t.string   "firstName"
    t.string   "middleName"
    t.string   "lastName"
    t.string   "personalId"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.string   "profilePicture"
    t.string   "status"
    t.integer  "employee_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "users", ["employee_id"], name: "index_users_on_employee_id", using: :btree

  create_table "vdm_changes", force: :cascade do |t|
    t.date     "changeDate"
    t.text     "changeDetail"
    t.string   "changedFrom"
    t.string   "changedTo"
    t.integer  "vdm_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "vdm_changes", ["user_id"], name: "index_vdm_changes_on_user_id", using: :btree
  add_index "vdm_changes", ["vdm_id"], name: "index_vdm_changes_on_vdm_id", using: :btree

  create_table "vdms", force: :cascade do |t|
    t.string   "videoId"
    t.string   "videoTittle"
    t.text     "videoContent"
    t.string   "status"
    t.text     "comments"
    t.text     "description"
    t.integer  "classes_planification_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "number"
  end

  add_index "vdms", ["classes_planification_id"], name: "index_vdms_on_classes_planification_id", using: :btree

  add_foreign_key "classes_planifications", "subject_planifications"
  add_foreign_key "roles", "users"
  add_foreign_key "subject_planifications", "subjects"
  add_foreign_key "subject_planifications", "teachers"
  add_foreign_key "subject_planifications", "users"
  add_foreign_key "subjects", "grades"
  add_foreign_key "users", "employees"
  add_foreign_key "vdm_changes", "users"
  add_foreign_key "vdm_changes", "vdms"
  add_foreign_key "vdms", "classes_planifications"
end
