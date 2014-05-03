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

ActiveRecord::Schema.define(version: 20140502220057) do

  create_table "jobs", force: true do |t|
    t.integer  "size",           limit: 8
    t.integer  "start",          limit: 8
    t.integer  "length",         limit: 8
    t.string   "reference_file"
    t.string   "operation"
    t.string   "storage_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "aasm_state"
    t.float    "work_starts"
    t.float    "work_ends"
    t.string   "tag"
    t.string   "object_id"
  end

end
