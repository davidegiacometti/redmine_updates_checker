desc <<-END_DESC
Check if there upates available

Example:
  rake redmine:updates:check RAILS_ENV="production"
END_DESC

namespace :redmine do
  namespace :updates do
    task :check => :environment do
      UpdatesChecker.check
    end
  end
end
