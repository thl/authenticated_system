class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions, :options => 'CHARACTER SET=utf8' do |t|
      t.column :title, :string, :limit => 60, :null => false
      t.column :description, :text
    end
    add_index :permissions, :title, :unique => true
    role = AuthenticatedSystem::Role.find(1)
    p = role.permissions.create :title => 'authenticated_system/roles/index'
    p = role.permissions.create :title => 'authenticated_system/roles/show'
    p = role.permissions.create :title => 'authenticated_system/roles/edit'
    p = role.permissions.create :title => 'authenticated_system/roles/update'
    p = role.permissions.create :title => 'main/admin'
  end

  def self.down
    drop_table :permissions
  end
end
