class AddQuizIndexes < ActiveRecord::Migration
  def self.up
    add_index :quizzes, :name, :unique => true
  end

  def self.down
    remove_index :quizzes, :name
  end
end
