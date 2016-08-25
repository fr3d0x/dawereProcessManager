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

ActiveRecord::Schema.define(version: 20160819141150) do

  create_table "classes_planifications", force: :cascade do |t|
    t.string   "meGeneralObjective",       limit: 255
    t.string   "meSpecificObjective",      limit: 255
    t.text     "meSpecificObjDesc",        limit: 65535
    t.string   "topicName",                limit: 255
    t.string   "videos",                   limit: 255
    t.integer  "subject_planification_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "status",                   limit: 255
    t.integer  "period",                   limit: 4
  end

  add_index "classes_planifications", ["subject_planification_id"], name: "index_classes_planifications_on_subject_planification_id", using: :btree

  create_table "cp_changes", force: :cascade do |t|
    t.date     "changeDate"
    t.string   "changeDetail",             limit: 255
    t.text     "changedFrom",              limit: 65535
    t.text     "changedTo",                limit: 65535
    t.text     "comments",                 limit: 65535
    t.string   "uname",                    limit: 255
    t.integer  "classes_planification_id", limit: 4
    t.integer  "user_id",                  limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "topicName",                limit: 255
  end

  add_index "cp_changes", ["classes_planification_id"], name: "index_cp_changes_on_classes_planification_id", using: :btree
  add_index "cp_changes", ["user_id"], name: "index_cp_changes_on_user_id", using: :btree

  create_table "design_assignments", force: :cascade do |t|
    t.string   "status",        limit: 255
    t.string   "assignedName",  limit: 255
    t.text     "comments",      limit: 65535
    t.integer  "user_id",       limit: 4
    t.integer  "design_dpt_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "design_assignments", ["design_dpt_id"], name: "index_design_assignments_on_design_dpt_id", using: :btree
  add_index "design_assignments", ["user_id"], name: "index_design_assignments_on_user_id", using: :btree

  create_table "design_dpts", force: :cascade do |t|
    t.string   "status",     limit: 255
    t.text     "comments",   limit: 65535
    t.integer  "vdm_id",     limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "design_dpts", ["vdm_id"], name: "index_design_dpts_on_vdm_id", using: :btree

  create_table "employees", force: :cascade do |t|
    t.string   "firstName",     limit: 255
    t.string   "middleName",    limit: 255
    t.string   "firstSurname",  limit: 255
    t.string   "secondSurname", limit: 255
    t.float    "currentSalary", limit: 24
    t.date     "birthDate"
    t.string   "personalId",    limit: 255
    t.string   "rif",           limit: 255
    t.string   "jobTittle",     limit: 255
    t.date     "admissionDate"
    t.string   "phone",         limit: 255
    t.string   "cellphone",     limit: 255
    t.text     "address",       limit: 65535
    t.string   "email",         limit: 255
    t.string   "email2",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "gender",        limit: 255
  end

  create_table "grades", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "post_prod_dpt_assignments", force: :cascade do |t|
    t.string   "status",           limit: 255
    t.string   "assignedName",     limit: 255
    t.text     "comments",         limit: 65535
    t.integer  "user_id",          limit: 4
    t.integer  "post_prod_dpt_id", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "post_prod_dpt_assignments", ["post_prod_dpt_id"], name: "index_post_prod_dpt_assignments_on_post_prod_dpt_id", using: :btree
  add_index "post_prod_dpt_assignments", ["user_id"], name: "index_post_prod_dpt_assignments_on_user_id", using: :btree

  create_table "post_prod_dpts", force: :cascade do |t|
    t.string   "status",     limit: 255
    t.text     "comments",   limit: 65535
    t.integer  "vdm_id",     limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "post_prod_dpts", ["vdm_id"], name: "index_post_prod_dpts_on_vdm_id", using: :btree

  create_table "product_managements", force: :cascade do |t|
    t.string   "productionStatus",     limit: 255
    t.string   "editionStatus",        limit: 255
    t.string   "designStatus",         limit: 255
    t.string   "postProductionStatus", limit: 255
    t.integer  "vdm_id",               limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "product_managements", ["vdm_id"], name: "index_product_managements_on_vdm_id", using: :btree

  create_table "production_dpt_assignments", force: :cascade do |t|
    t.string   "status",            limit: 255
    t.string   "assignedName",      limit: 255
    t.text     "comments",          limit: 65535
    t.integer  "user_id",           limit: 4
    t.integer  "production_dpt_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "production_dpt_assignments", ["production_dpt_id"], name: "index_production_dpt_assignments_on_production_dpt_id", using: :btree
  add_index "production_dpt_assignments", ["user_id"], name: "index_production_dpt_assignments_on_user_id", using: :btree

  create_table "production_dpts", force: :cascade do |t|
    t.string   "status",     limit: 255
    t.text     "script",     limit: 4294967295
    t.text     "comments",   limit: 65535
    t.boolean  "intro",      limit: 1
    t.boolean  "vidDev",     limit: 1
    t.boolean  "conclu",     limit: 1
    t.integer  "vdm_id",     limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "production_dpts", ["vdm_id"], name: "index_production_dpts_on_vdm_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "role",       limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "primary",    limit: 1
  end

  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

  create_table "subject_planifications", force: :cascade do |t|
    t.string   "status",               limit: 255
    t.integer  "teacher_id",           limit: 4
    t.integer  "subject_id",           limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id",              limit: 4
    t.boolean  "firstPeriodCompleted", limit: 1
  end

  add_index "subject_planifications", ["subject_id"], name: "index_subject_planifications_on_subject_id", using: :btree
  add_index "subject_planifications", ["teacher_id"], name: "index_subject_planifications_on_teacher_id", using: :btree
  add_index "subject_planifications", ["user_id"], name: "index_subject_planifications_on_user_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "shortDescription", limit: 65535
    t.text     "longDescription",  limit: 65535
    t.text     "firstPeriodDesc",  limit: 65535
    t.text     "secondPeriodDesc", limit: 65535
    t.text     "thirdPeriodDesc",  limit: 65535
    t.text     "goal",             limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "grade_id",         limit: 4
  end

  add_index "subjects", ["grade_id"], name: "index_subjects_on_grade_id", using: :btree

  create_table "teachers", force: :cascade do |t|
    t.text     "cvLong",     limit: 65535
    t.text     "cvShort",    limit: 65535
    t.string   "firstName",  limit: 255
    t.string   "middleName", limit: 255
    t.string   "lastName",   limit: 255
    t.string   "personalId", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",       limit: 255
    t.string   "password",       limit: 255
    t.string   "profilePicture", limit: 255
    t.string   "status",         limit: 255
    t.integer  "employee_id",    limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "users", ["employee_id"], name: "index_users_on_employee_id", using: :btree

  create_table "vdm_changes", force: :cascade do |t|
    t.date     "changeDate"
    t.text     "changeDetail", limit: 65535
    t.text     "changedFrom",  limit: 4294967295
    t.text     "changedTo",    limit: 4294967295
    t.integer  "vdm_id",       limit: 4
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "comments",     limit: 65535
    t.string   "uname",        limit: 255
    t.string   "videoId",      limit: 255
    t.string   "department",   limit: 255
  end

  add_index "vdm_changes", ["user_id"], name: "index_vdm_changes_on_user_id", using: :btree
  add_index "vdm_changes", ["vdm_id"], name: "index_vdm_changes_on_vdm_id", using: :btree

  create_table "vdms", force: :cascade do |t|
    t.string   "videoId",                  limit: 255
    t.string   "videoTittle",              limit: 255
    t.text     "videoContent",             limit: 65535
    t.string   "status",                   limit: 255
    t.text     "comments",                 limit: 65535
    t.integer  "classes_planification_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "number",                   limit: 4
  end

  add_index "vdms", ["classes_planification_id"], name: "index_vdms_on_classes_planification_id", using: :btree

  add_foreign_key "classes_planifications", "subject_planifications"
  add_foreign_key "cp_changes", "classes_planifications"
  add_foreign_key "cp_changes", "users"
  add_foreign_key "design_assignments", "design_dpts"
  add_foreign_key "design_assignments", "users"
  add_foreign_key "design_dpts", "vdms"
  add_foreign_key "post_prod_dpt_assignments", "post_prod_dpts"
  add_foreign_key "post_prod_dpt_assignments", "users"
  add_foreign_key "post_prod_dpts", "vdms"
  add_foreign_key "product_managements", "vdms"
  add_foreign_key "production_dpt_assignments", "production_dpts"
  add_foreign_key "production_dpt_assignments", "users"
  add_foreign_key "production_dpts", "vdms"
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
