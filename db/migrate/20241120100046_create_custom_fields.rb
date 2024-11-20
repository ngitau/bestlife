class CreateCustomFields < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_fields do |t|
      t.string :name, null: false
      t.string :associated_model

      t.timestamps
    end
  end
end
