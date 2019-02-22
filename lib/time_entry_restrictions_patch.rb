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
        user = User.current

        if !Setting.plugin_redmine_log_hours_restrictions['daily_hours_limit'].to_i.zero?
            record.errors.add :base, I18n.t(:time_entry_restiction_day_per_day, :num => Setting.plugin_redmine_log_hours_restrictions['daily_hours_limit']) if !can_log_hours?(user, record)
        end

        if Setting.plugin_redmine_log_hours_restrictions['do_not_track_in_future'] and record.spent_on > today
            record.errors.add :base, I18n.t(:time_entry_restiction_future_day)
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

      class << base

        def can_log_hours?(user, record)
          if record.new_record?
            logged_hours = TimeEntry.where(:user_id => user.id).where('DATE(spent_on) = ?', record.spent_on)
          else
            logged_hours = TimeEntry.where(:user_id => user.id).where('DATE(spent_on) = ?', record.spent_on).where(TimeEntry.arel_table[:id].not_eq(record.id))
            time_entry_hours_before_edit = TimeEntry.where(:id => record.id).first.hours
            if time_entry_hours_before_edit > record.hours:
              return true
            end
          end
          logged_hours_sum = logged_hours.sum(:hours)
          avaialable_to_log_hours = (Setting.plugin_redmine_log_hours_restrictions['daily_hours_limit'].to_i - logged_hours_sum)
          avaialable_to_log_hours = 0 if avaialable_to_log_hours < 0
          puts avaialable_to_log_hours
          puts logged_hours_sum
          result = record.hours <= avaialable_to_log_hours
        end

      end

    end

  end

end


Rails.configuration.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
end