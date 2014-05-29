# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require File.expand_path('../../config/environment', __FILE__)
every :reboot do
  if daemon = CONFIG['daemon']['path']
    command daemon
  end
end

if delay = CONFIG['tipper_delay']
  delay = eval(delay)
  every delay do
    runner "BalanceUpdater.work; BitcoinTipper.work; BalanceUpdater.work"
  end
end
