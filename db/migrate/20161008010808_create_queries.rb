class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :query, null: false
      t.string :status, null: false

      t.timestamps null: false
    end
  end
end
