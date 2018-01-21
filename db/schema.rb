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

ActiveRecord::Schema.define(version: 20180121184454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cold_storage_transfers", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "amount",        limit: 8
    t.string   "address",       limit: 255
    t.string   "txid",          limit: 255
    t.integer  "confirmations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fee"
  end

  add_index "cold_storage_transfers", ["project_id"], name: "index_cold_storage_transfers_on_project_id", using: :btree

  create_table "collaborators", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "login",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "collaborators", ["project_id"], name: "index_collaborators_on_project_id", using: :btree
  add_index "collaborators", ["user_id"], name: "index_collaborators_on_user_id", using: :btree

  create_table "commits", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "sha",        limit: 255
    t.text     "message"
    t.string   "username",   limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commits", ["project_id"], name: "index_commits_on_project_id", using: :btree

  create_table "commontator_comments", force: :cascade do |t|
    t.string   "creator_type",      limit: 255
    t.integer  "creator_id"
    t.string   "editor_type",       limit: 255
    t.integer  "editor_id"
    t.integer  "thread_id",                                 null: false
    t.text     "body",                                      null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_up",               default: 0
    t.integer  "cached_votes_down",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_comments", ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down", using: :btree
  add_index "commontator_comments", ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up", using: :btree
  add_index "commontator_comments", ["creator_id", "creator_type", "thread_id"], name: "index_commontator_comments_on_c_id_and_c_type_and_t_id", using: :btree
  add_index "commontator_comments", ["thread_id"], name: "index_commontator_comments_on_thread_id", using: :btree

  create_table "commontator_subscriptions", force: :cascade do |t|
    t.string   "subscriber_type", limit: 255, null: false
    t.integer  "subscriber_id",               null: false
    t.integer  "thread_id",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_subscriptions", ["subscriber_id", "subscriber_type", "thread_id"], name: "index_commontator_subscriptions_on_s_id_and_s_type_and_t_id", unique: true, using: :btree
  add_index "commontator_subscriptions", ["thread_id"], name: "index_commontator_subscriptions_on_thread_id", using: :btree

  create_table "commontator_threads", force: :cascade do |t|
    t.string   "commontable_type", limit: 255
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type",      limit: 255
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_threads", ["commontable_id", "commontable_type"], name: "index_commontator_threads_on_c_id_and_c_type", unique: true, using: :btree

  create_table "deposits", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "txid",                limit: 255
    t.integer  "confirmations"
    t.integer  "duration",                        default: 2592000
    t.integer  "paid_out",            limit: 8
    t.datetime "paid_out_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",              limit: 8
    t.integer  "donation_address_id"
  end

  add_index "deposits", ["donation_address_id"], name: "index_deposits_on_donation_address_id", using: :btree
  add_index "deposits", ["project_id"], name: "index_deposits_on_project_id", using: :btree

  create_table "distributions", force: :cascade do |t|
    t.string   "txid",       limit: 255
    t.text     "data"
    t.string   "result",     limit: 255
    t.boolean  "is_error"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "fee"
    t.datetime "sent_at"
  end

  add_index "distributions", ["project_id"], name: "index_distributions_on_project_id", using: :btree

  create_table "donation_addresses", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "sender_address",   limit: 255
    t.string   "donation_address", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "donation_addresses", ["project_id"], name: "index_donation_addresses_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "url",                             limit: 255
    t.string   "bitcoin_address",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                            limit: 255
    t.string   "full_name",                       limit: 255
    t.string   "source_full_name",                limit: 255
    t.text     "description"
    t.integer  "watchers_count"
    t.string   "language",                        limit: 255
    t.string   "last_commit",                     limit: 255
    t.integer  "available_amount_cache",          limit: 8
    t.string   "address_label",                   limit: 255
    t.boolean  "hold_tips",                                   default: true
    t.string   "cold_storage_withdrawal_address", limit: 255
    t.boolean  "disabled",                                    default: false
    t.integer  "account_balance",                 limit: 8
    t.string   "disabled_reason",                 limit: 255
    t.text     "detailed_description"
    t.integer  "stake_mint_amount",               limit: 8
  end

  create_table "record_changes", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "record_type", limit: 255
    t.integer  "user_id"
    t.text     "raw_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "record_changes", ["record_id", "record_type"], name: "index_record_changes_on_record_id_and_record_type", using: :btree

  create_table "tipping_policies_texts", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tipping_policies_texts", ["project_id"], name: "index_tipping_policies_texts_on_project_id", using: :btree
  add_index "tipping_policies_texts", ["user_id"], name: "index_tipping_policies_texts_on_user_id", using: :btree

  create_table "tips", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "amount",          limit: 8
    t.integer  "distribution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commit",          limit: 255
    t.integer  "project_id"
    t.datetime "refunded_at"
    t.string   "commit_message",  limit: 255
    t.string   "comment",         limit: 255
    t.integer  "reason_id"
    t.string   "reason_type",     limit: 255
  end

  add_index "tips", ["distribution_id"], name: "index_tips_on_distribution_id", using: :btree
  add_index "tips", ["project_id"], name: "index_tips_on_project_id", using: :btree
  add_index "tips", ["reason_id", "reason_type"], name: "index_tips_on_reason_id_and_reason_type", using: :btree
  add_index "tips", ["user_id"], name: "index_tips_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname",               limit: 255
    t.string   "name",                   limit: 255
    t.string   "image",                  limit: 255
    t.string   "bitcoin_address",        limit: 255
    t.string   "login_token",            limit: 255
    t.boolean  "unsubscribed"
    t.datetime "notified_at"
    t.integer  "commits_count",                      default: 0
    t.integer  "withdrawn_amount",       limit: 8,   default: 0
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.boolean  "disabled",                           default: false
    t.string   "identifier",             limit: 255,                 null: false
  end

  add_index "users", ["disabled"], name: "index_users_on_disabled", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["identifier"], name: "index_users_on_identifier", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
