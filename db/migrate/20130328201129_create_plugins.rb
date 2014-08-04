class CreatePlugins < ActiveRecord::Migration
  def change
    create_table :plugins do |t|
      t.string :plugin
      t.datetime :updated_at
      t.string :ip_address

      t.timestamps
    end
  end
end
