#!/usr/bin/env ruby

require 'time'

# The NTP log file timestamp epoch begins at 1858-11-17 00:00:00 UTC 
# See: Modified Julian Date - https://en.wikipedia.org/wiki/Julian_day
def ntp_epoch_start
  @ntp_epoch_start ||= Time.parse("1858-11-17 00:00:00 UTC")
end

# add some convenience to Time, probably unnecessary but whatever
class Time
  class << self
    alias_method :old_at, :at

    def at(timestamp)
      timestamp = timestamp.to_i if timestamp.to_i.to_s == timestamp
      old_at(timestamp)
    end
  end

  def add_days(days)
    return self + (days.to_i * 86400)
  end

  def add_secs(secs)
    return self + secs.to_i
  end
end

# Naïve arg length sanity check and usage info
if ARGV.length == 0
  puts "please supply filenames(s) for conversion, e.g.:"
  puts "#{$0} peers-20170401 peers-20170402"
  exit 1
end

# File::foreach gives us individual lines as strings to play with
# Try to figure out what kind of logfile we're dealing with, and convert appropriately
def convert_line(line, filename)
  if filename.include?('loops') || filename.include?('peers')
    convert_ntp_line(line)
  elsif filename.include?('message')
    convert_message_line(line)
  elsif filename.include?('nagios')
    convert_nagios_line(line)
  else 
    convert_ntp_line(line) # give up, fall back on original behavior
  end 
end

# 57844 27156.724 127.0.0.1 9014 0.005995526 0.032311653 3.937740536 0.002301804
def convert_ntp_line(line)
  line_array = line.split(' ')
  days = line_array[0]
  secs = line_array[1]
  human_timestamp = ntp_epoch_start.add_days(days).add_secs(secs)
  format(human_timestamp, line_array, 2)
end

# Jan  1 00:00:00 rest of the log message goes here
def convert_message_line(line)
  line_array = line.split(' ')
  human_timestamp = Time.parse(line_array[0..2].join(' '))
  format(human_timestamp, line_array, 3)
end

# [1490289098] SERVICE ALERT: hostname and other message stuff here
# where the bit in brackets is an epoch timestamp :(
def convert_nagios_line(line)
  line_array = line.split(' ')
  epoch_timestamp = line_array[0].gsub(/\D/, '')
  human_timestamp = Time.at(epoch_timestamp)
  format(human_timestamp, line_array, 1)
end

# Format the timestamp consistently and smash everything back into a string
def format(human_timestamp, line_array, offset)
  human_timestamp.getlocal.strftime('%Y-%m-%d %H:%M:%S%z') + ' ' + line_array[offset..-1].join(' ')
end

# For each filename we're given, open (truncating existing file) a file to hold the converted stuff
# naming the new file "filename.converted"
# then convert each line in our input file and append it to the new .converted file
ARGV.each do |filename|
  File.open(filename + '.converted', 'w') do |converted_file|    
    File.foreach(filename) { |line| converted_file << convert_line(line, filename) << "\n" }
  end
end


