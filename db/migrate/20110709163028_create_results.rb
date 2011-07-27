class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.integer :evaluation_id
      t.integer :question_id
      t.string :result

      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
