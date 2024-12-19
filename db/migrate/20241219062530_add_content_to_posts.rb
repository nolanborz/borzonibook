class AddContentToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :content, :text
  end
end
