namespace :authenticated_system do
  desc "Syncronize extra files for Authenticated System plugin."
  task :sync do
    system "rsync -ruv --exclude '.*' vendor/plugins/authenticated_system/db/migrate db"
    system "rsync -ruv --exclude '.*' vendor/plugins/authenticated_system/public ."
  end
end