class CreateCallbackSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :callback_settings do |t|
      t.string :callback_type
      t.string :url
      t.string :mode
      t.integer :bunch_size

      t.timestamps
    end
  end
end
