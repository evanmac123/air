#!/usr/bin/env ruby

require 'csv'

SUFFIXES = ["jr", "jr.", "iii", "ii", "sr", "iv", "sr.", "v"]

def make_claim_code(fname, lname)
  fname = fname.dup.downcase
  lname = lname.dup.downcase

  finitial = fname[0, 1]
  lname_parts = lname.split
  while(SUFFIXES.include? lname_parts.last)
    lname_parts.pop
  end

  (finitial + lname_parts.join('')).gsub(/[^A-Za-z]/, '')
end

STDIN.each do |line|
  data = CSV.parse(line).first
  data[5] = data[5].strip.capitalize
  data[6] = data[6].strip.capitalize

  data << make_claim_code(data[5], data[6])

  puts CSV.generate_line(data)
end
