#!/usr/bin/env ruby

require 'time'

# The NTP log file timestamp epoch begins at 1858-11-17 00:00:00 UTC 
# See: Modified Julian Date - https://en.wikipedia.org/wiki/Julian_day
def epoch_start
  @epoch_start ||= Time.parse("1858-11-17 00:00:00 UTC")
end

# add some convenience to Time, probably unnecessary but whatever
class Time
  def add_ntp_days(days)
    return self + (days.to_i * 86400)
  end

  def add_ntp_secs(secs)
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
def convert_line(line)
  # Make it into an array
  line_array = line.split(' ')

  # Grab the "days since epoch" and "seconds since midnight (UTC)" fields
  days = line_array[0]
  secs = line_array[1]

  # Add them both to the epoch start time
  human_timestamp = epoch_start.add_ntp_days(days).add_ntp_secs(secs)

  # And smash it back together into one string
  human_timestamp.getlocal.strftime('%Y-%m-%d %H:%M:%S%z') + ' ' + line_array[2..-1].join(' ')
end

# For each filename we're given, open (truncating existing file) a file to hold the converted stuff
# naming the new file "filename.converted"
# then convert each line in our input file and append it to the new .converted file
ARGV.each do |filename|
  File.open(filename + '.converted', 'w') do |converted_file|    
    File.foreach(filename) { |line| converted_file << convert_line(line) << "\n" }
  end
end


