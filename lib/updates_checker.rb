require 'json'
require 'httparty'
require "#{Rails.root}/app/helpers/admin_helper.rb"
include AdminHelper

class UpdatesChecker
  def self.check
    now = DateTime.now
    plugins = Redmine::Plugin.all
    settings = Setting.plugin_redmine_updates_checker
    default_from = Setting.mail_from
    result = {
      'updated' => [],
      'updatable' => [],
      'unknown' => []
    }

    # Updates check
    query_string = plugin_data_for_updates(plugins)
    response = HTTParty.get 'http://www.redmine.org/plugins/check_updates', :query => query_string
    # Parsing result
    if response.code == 200
      json_response = JSON.parse(response.body.gsub(/^\(/, '').gsub(/\)$/, ''))
      plugins.each do |p|
        next if settings['excluded_plugins'] != nil && settings['excluded_plugins'].include?(p.id.to_s)
        if !json_response.key?(p.id.to_s)
          result['unknown'] << { 'name' => p.name.to_s, 'current_version' => p.version.to_s }
        else
          available_version = json_response[p.id.to_s]['c']
          if available_version.blank? 
            result['unknown'] << { 'name' => p.name.to_s, 'current_version' => p.version.to_s }
          elsif available_version != p.version.to_s
            result['updatable'] << { 'name' => p.name.to_s, 'current_version' => p.version.to_s, 'available_version' => available_version }
          else
            result['updated'] << { 'name' => p.name.to_s, 'current_version' => p.version.to_s }
          end
        end
      end

      notify_updateable = result['updatable'].any? && settings['notify_updatable'] == '1' 
      notify_updated = result['updated'].any? && settings['notify_updated'] == '1'
      notify_unknown = result['unknown'].any? && settings['notify_unknown'] == '1'

      unless notify_updateable || notify_updated || notify_unknown
        return
      end

      # Output
      body = "Date: #{now.strftime("%F %T")}\n"
      body += "Server: #{Socket.gethostname}\n\n"
  
      if notify_updateable
        body += "New version available:\n"
        result['updatable'].sort_by{ |p| p['name'] }.each do |p|
          body += "\t- #{p['name']} #{p['current_version']} -> #{p['available_version']}\n"
        end
        body += "\n"
      end
  
      if notify_updated
        body += "Updated:\n"
        result['updated'].sort_by{ |p| p['name'] }.each do |p|
          body += "\t- #{p['name']} #{p['current_version']}\n"
        end
        body += "\n"
      end
  
      if notify_unknown
        body += "Unknown:\n"
        result['unknown'].sort_by{ |p| p['name'] }.each do |p|
          body += "\t- #{p['name']} #{p['current_version']}\n"
        end
        body += "\n"
      end

      if settings['email_recipients'].length > 0
        ActionMailer::Base.mail(
        from: default_from, 
        to: settings['email_recipients'], 
        subject: 'Redmine Updates Checker', 
        body: body
        ).deliver_now
      end
    else
      # TODO error handling
    end
  end
end
