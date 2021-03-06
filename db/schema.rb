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

ActiveRecord::Schema.define(version: 20161212074861) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,        default: 0, null: false
    t.integer  "attempts",   limit: 4,        default: 0, null: false
    t.text     "handler",    limit: 16777215,             null: false
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["failed_at", "attempts"], name: "index_delayed_jobs_on_failed_at_and_attempts", using: :btree
  add_index "delayed_jobs", ["failed_at"], name: "index_delayed_jobs_on_failed_at", using: :btree
  add_index "delayed_jobs", ["locked_at", "failed_at"], name: "index_delayed_jobs_on_locked_at_and_failed_at", using: :btree
  add_index "delayed_jobs", ["locked_at"], name: "index_delayed_jobs_on_locked_at", using: :btree
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "shows", force: :cascade do |t|
    t.string   "title",                    limit: 255
    t.string   "slug",                     limit: 255
    t.string   "url",                      limit: 255
    t.string   "filename",                 limit: 255
    t.string   "image",                    limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.float    "duration",                 limit: 24
    t.string   "cover_image_file_name",    limit: 255
    t.string   "cover_image_content_type", limit: 255
    t.integer  "cover_image_file_size",    limit: 4
    t.datetime "cover_image_updated_at"
  end

end
