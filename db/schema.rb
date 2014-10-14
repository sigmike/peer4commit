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

ActiveRecord::Schema.define(version: 20140714074128) do

  create_table "cold_storage_transfers", force: true do |t|
    t.integer  "project_id"
    t.integer  "amount",        limit: 8
    t.string   "address"
    t.string   "txid"
    t.integer  "confirmations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fee"
  end

  add_index "cold_storage_transfers", ["project_id"], name: "index_cold_storage_transfers_on_project_id"

  create_table "collaborators", force: true do |t|
    t.integer  "project_id"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "collaborators", ["project_id"], name: "index_collaborators_on_project_id"
  add_index "collaborators", ["user_id"], name: "index_collaborators_on_user_id"

  create_table "commits", force: true do |t|
    t.integer  "project_id"
    t.string   "sha"
    t.text     "message"
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commits", ["project_id"], name: "index_commits_on_project_id"

  create_table "commontator_comments", force: true do |t|
    t.string   "creator_type"
    t.integer  "creator_id"
    t.string   "editor_type"
    t.integer  "editor_id"
    t.integer  "thread_id",                     null: false
    t.text     "body",                          null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_up",   default: 0
    t.integer  "cached_votes_down", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_comments", ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down"
  add_index "commontator_comments", ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up"
  add_index "commontator_comments", ["creator_id", "creator_type", "thread_id"], name: "index_commontator_comments_on_c_id_and_c_type_and_t_id"
  add_index "commontator_comments", ["thread_id"], name: "index_commontator_comments_on_thread_id"

  create_table "commontator_subscriptions", force: true do |t|
    t.string   "subscriber_type", null: false
    t.integer  "subscriber_id",   null: false
    t.integer  "thread_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_subscriptions", ["subscriber_id", "subscriber_type", "thread_id"], name: "index_commontator_subscriptions_on_s_id_and_s_type_and_t_id", unique: true
  add_index "commontator_subscriptions", ["thread_id"], name: "index_commontator_subscriptions_on_thread_id"

  create_table "commontator_threads", force: true do |t|
    t.string   "commontable_type"
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type"
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_threads", ["commontable_id", "commontable_type"], name: "index_commontator_threads_on_c_id_and_c_type", unique: true

  create_table "deposits", force: true do |t|
    t.integer  "project_id"
    t.string   "txid"
    t.integer  "confirmations"
    t.integer  "duration",                      default: 2592000
    t.integer  "paid_out",            limit: 8
    t.datetime "paid_out_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",              limit: 8
    t.integer  "donation_address_id"
  end

  add_index "deposits", ["donation_address_id"], name: "index_deposits_on_donation_address_id"
  add_index "deposits", ["project_id"], name: "index_deposits_on_project_id"

  create_table "distributions", force: true do |t|
    t.string   "txid"
    t.text     "data"
    t.string   "result"
    t.boolean  "is_error"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "fee"
    t.datetime "sent_at"
  end

  add_index "distributions", ["project_id"], name: "index_distributions_on_project_id"

  create_table "donation_addresses", force: true do |t|
    t.integer  "project_id"
    t.string   "sender_address"
    t.string   "donation_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "donation_addresses", ["project_id"], name: "index_donation_addresses_on_project_id"

  create_table "projects", force: true do |t|
    t.string   "url"
    t.string   "bitcoin_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "full_name"
    t.string   "source_full_name"
    t.text     "description"
    t.integer  "watchers_count"
    t.string   "language"
    t.string   "last_commit"
    t.integer  "available_amount_cache",          limit: 8
    t.string   "address_label"
    t.boolean  "hold_tips",                                 default: true
    t.string   "cold_storage_withdrawal_address"
    t.boolean  "disabled",                                  default: false
    t.integer  "account_balance",                 limit: 8
    t.string   "disabled_reason"
    t.text     "detailed_description"
  end

  create_table "record_changes", force: true do |t|
    t.integer  "record_id"
    t.string   "record_type"
    t.integer  "user_id"
    t.text     "raw_state",   limit: 1048576
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "record_changes", ["record_id", "record_type"], name: "index_record_changes_on_record_id_and_record_type"

  create_table "tipping_policies_texts", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tipping_policies_texts", ["project_id"], name: "index_tipping_policies_texts_on_project_id"
  add_index "tipping_policies_texts", ["user_id"], name: "index_tipping_policies_texts_on_user_id"

  create_table "tips", force: true do |t|
    t.integer  "user_id"
    t.integer  "amount",          limit: 8
    t.integer  "distribution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commit"
    t.integer  "project_id"
    t.datetime "refunded_at"
    t.string   "commit_message"
    t.string   "comment"
    t.integer  "reason_id"
    t.string   "reason_type"
  end

  add_index "tips", ["distribution_id"], name: "index_tips_on_distribution_id"
  add_index "tips", ["project_id"], name: "index_tips_on_project_id"
  add_index "tips", ["reason_id", "reason_type"], name: "index_tips_on_reason_id_and_reason_type"
  add_index "tips", ["user_id"], name: "index_tips_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                            default: "",    null: false
    t.string   "encrypted_password",               default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
    t.string   "name"
    t.string   "image"
    t.string   "bitcoin_address"
    t.string   "login_token"
    t.boolean  "unsubscribed"
    t.datetime "notified_at"
    t.integer  "commits_count",                    default: 0
    t.integer  "withdrawn_amount",       limit: 8, default: 0
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "disabled",                         default: false
    t.string   "identifier",                                       null: false
  end

  add_index "users", ["disabled"], name: "index_users_on_disabled"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["identifier"], name: "index_users_on_identifier", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
