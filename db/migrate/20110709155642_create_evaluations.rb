class CreateEvaluations < ActiveRecord::Migration
  def self.up
    create_table :evaluations do |t|
      t.integer :quiz_id
      t.integer :parent_id
      t.boolean :completed, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluations
  end
end
