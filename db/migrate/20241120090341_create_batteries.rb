class CreateBatteries < ActiveRecord::Migration[8.0]
  def change
    create_table :batteries do |t|
      t.integer :capacity

      t.timestamps
    end
  end
end
