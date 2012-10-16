class AddShibbolethIdToUser < ActiveRecord::Migration
  def change
    add_column :authenticated_system_users, :shibboleth_id, :string
  end
end
