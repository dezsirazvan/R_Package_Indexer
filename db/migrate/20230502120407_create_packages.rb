class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.string :r_version_needed
      t.string :title
      t.datetime :date_publication
      t.string :authors
      t.string :maintainers
      t.string :license
      t.string :dependencies

      t.timestamps
    end
  end
end
