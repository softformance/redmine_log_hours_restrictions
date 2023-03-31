require 'redmine'

require 'time_entry_restrictions_patch'

Redmine::Plugin.register :redmine_log_hours_restrictions do
  name 'Redmine Log Hours Restrictions plugin'
  author 'Dmytro Litvinov'
  description 'Redmine plugin which allows configure the settings for logging.'
  version '0.0.3'
  url 'https://github.com/SoftFormance/redmine_log_hours_restrictions'
  author_url 'https://DmytroLitvinov.com'
  requires_redmine :version_or_higher => '4.0'

  settings(:partial => 'settings/log_hours_restrictions_settings',
           :default => {
             :do_not_track_past_hours => true, 
             :do_not_track_hours_for_the_past_week => true, 
             :do_not_track_hours_for_the_past_month => true,
             :do_not_track_in_future => true,
         })
end