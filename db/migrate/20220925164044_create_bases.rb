class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.integer :baseno
      t.string :basename
      t.string :basekind

      t.timestamps
    end
  end
end
