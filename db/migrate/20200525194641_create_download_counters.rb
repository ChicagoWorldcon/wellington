class CreateDownloadCounters < ActiveRecord::Migration[6.0]
  def change
    create_table :download_counters do |t|
      t.references :user, index: true, null: false, foreign_key: true
      t.integer :count
      t.timestamps
    end
  end
end
