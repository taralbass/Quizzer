class AddResultIndexes < ActiveRecord::Migration
  def self.up
    add_index :results, [ :evaluation_id, :result ]
    add_index :results, [ :evaluation_id, :question_id ], :unique => true
  end

  def self.down
    remove_index :results, [ :evaluation_id, :question_id ]
    remove_index :results, [ :evaluation_id, :result ]
  end
end
