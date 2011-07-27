class AddDescriptionToQuizzes < ActiveRecord::Migration
  def self.up
    add_column :quizzes, :description, :text
  end

  def self.down
    remove_column :quizzes, :description
  end
end
