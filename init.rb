require 'redmine'

require 'time_entry_restrictions_patch'

Redmine::Plugin.register :redmine_log_hours_restrictions do
  name 'Redmine Log Hours Restrictions plugin'
  author 'Dmytro Litvinov'
  description 'Redmine plugin which allows configuer per project logging hours.'
  version '0.0.1'
  url 'https://github.com/SoftFormance/redmine_log_hours_restrictions'
  author_url 'https://DmytroLitvinov.com'
  requires_redmine :version => '2.1.2'

  settings(:partial => 'settings/log_hours_restrictions_settings',
           :default => {
             :do_not_track_past_hours => true, 
             :do_not_track_hours_for_the_past_week => true, 
             :do_not_track_hours_for_the_past_month => true,
             :do_not_track_in_future => true,
             :daily_hours_limit => 0,
         })
end