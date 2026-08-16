class CreateSnacks < ActiveRecord::Migration[8.1]
  def change
    create_table :snacks do |t|
      t.string :brand
      t.string :name
      t.decimal :isaac_rating, precision: 3, scale: 1
      t.decimal :wife_rating,  precision: 3, scale: 1
      t.text :notes
      t.date :tried_on
      t.string :country_of_origin

      t.timestamps
    end
  end
end
