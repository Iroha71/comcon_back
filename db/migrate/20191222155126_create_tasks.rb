class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false, limit: 50
      t.string :detail, limit: 150
      t.date :limit_date
      t.references :priority, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: '未着手'

      t.timestamps
    end
  end
end
