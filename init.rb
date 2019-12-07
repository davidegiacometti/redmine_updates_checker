Redmine::Plugin.register :redmine_updates_checker do
  name 'Redmine Updates Checker Plugin'
  author 'Davide Giacometti'
  description 'Updates checker for Redmine plugins'
  version '0.0.1'
  url 'https://github.com/davidegiacometti/redmine_updates_checker'
  author_url 'https://github.com/davidegiacometti'

  settings :default => { 'notification_emails' => '', 'notify_updatable' => true, 'notify_unknown' => true }, :partial => "settings/updates_checker"
end
