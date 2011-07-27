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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110726161511) do

  create_table "answers", :force => true do |t|
    t.text     "text"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "evaluations", :force => true do |t|
    t.integer  "quiz_id"
    t.integer  "parent_id"
    t.boolean  "completed",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evaluations", ["quiz_id"], :name => "index_evaluations_on_quiz_id"

  create_table "questions", :force => true do |t|
    t.text     "text"
    t.integer  "quiz_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["quiz_id"], :name => "index_questions_on_quiz_id"

  create_table "quizzes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "published",   :default => false
  end

  add_index "quizzes", ["name"], :name => "index_quizzes_on_name", :unique => true

  create_table "results", :force => true do |t|
    t.integer  "evaluation_id"
    t.integer  "question_id"
    t.string   "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "results", ["evaluation_id", "question_id"], :name => "index_results_on_evaluation_id_and_question_id", :unique => true
  add_index "results", ["evaluation_id", "result"], :name => "index_results_on_evaluation_id_and_result"

end
