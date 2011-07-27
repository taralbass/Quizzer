class AddEvaluationIndexes < ActiveRecord::Migration
  def self.up
    add_index :evaluations, :quiz_id
  end

  def self.down
    remove_index :evaluations, :quiz_id
  end
end
