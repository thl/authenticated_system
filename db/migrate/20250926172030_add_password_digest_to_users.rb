class AddPasswordDigestToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_digest, :string
    add_index  :users, :password_digest
  end
end
