#!/usr/bin/env ruby

require 'csv'

class NilClass
  def present?
    false
  end
end

class String
  def present?
    self !~ /^\s*$/
  end
end

STDIN.each do |line|
  chorus_id, location, dob, gender, doh, first_name, last_name, zip, s_first_name, s_last_name, s_gender = CSV.parse(line).first

  puts(CSV.generate_line([chorus_id, location, dob, gender, doh, first_name, last_name, zip]))
  if (s_first_name.present? && s_last_name.present?)
    puts(CSV.generate_line([chorus_id, location, nil, s_gender, nil, s_first_name, s_last_name, zip]))
  end
end
