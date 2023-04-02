require 'date'
require 'active_support'

require_dependency 'time_entry'

module TimeLimitTimeEntryPatch
  def self.included(base)

    base.class_eval do
      unloadable

      validates_each :hours do |record, attr, value|
        today = Date.today  # need for "past hours" validaiton
        monday = today - (today.wday - 1) % 7  # need for "past week" validation
        saturday = today + (6 - today.wday) % 7
        sunday = today + (7 - today.wday) % 7
        user = User.current

        if Setting.plugin_redmine_log_hours_restrictions['do_not_track_in_future'] and record.spent_on > today
            record.errors.add :base, I18n.t(:time_entry_restiction_future_day)
        end

        if Setting.plugin_redmine_log_hours_restrictions['do_not_track_on_saturday'] and record.spent_on == saturday
          record.errors.add :base, I18n.t(:time_entry_restiction_satuday)
        elsif Setting.plugin_redmine_log_hours_restrictions['do_not_track_on_sunday'] and record.spent_on == sunday
          record.errors.add :base, I18n.t(:time_entry_restiction_sunday)
        end

        # Check past hours
        if Setting.plugin_redmine_log_hours_restrictions['do_not_track_past_hours'] and record.spent_on < today
          record.errors.add :base, I18n.t(:time_entry_restiction_day)
        # Check past week and earlier
        elsif Setting.plugin_redmine_log_hours_restrictions['do_not_track_hours_for_the_past_week'] and record.spent_on < monday
          record.errors.add :base, I18n.t(:time_entry_restiction_week)
        # Check previous month and earlier
        elsif Setting.plugin_redmine_log_hours_restrictions['do_not_track_hours_for_the_past_month'] and record.spent_on < Date.today.at_beginning_of_month
          record.errors.add :base, I18n.t(:time_entry_restiction_mounth)
        end

      end

    end

  end

end


Rails.configuration.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
end