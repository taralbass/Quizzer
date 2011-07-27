class AddPublishedToQuizzes < ActiveRecord::Migration
  def self.up
    add_column :quizzes, :published, :boolean, :default => 0
  end

  def self.down
    remove_column :quizzes, :published
  end
end
