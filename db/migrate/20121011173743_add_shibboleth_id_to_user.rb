class AddShibbolethIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :shibboleth_id, :string
  end
end
