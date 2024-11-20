class CreateCustomAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_attributes do |t|
      t.references :attributable, polymorphic: true, index: true, null: false
      t.string :key, null: false
      t.string :value

      t.timestamps
    end
  end
end