require "spec_helper"

describe CssSplitter::Splitter do
  def count_selectors file
    str = file.to_s
    rules = CssSplitter::Splitter.split_string_into_rules str
    return if rules.first.nil?
    rules.sum{ |rule| CssSplitter::Splitter.count_selectors_of_rule(rule) }
  end

  def get_file name
    Rails.application.assets[name + ".css"]
  end

  def max_selectors
    ENV['MAX_SELECTORS_DEFAULT'].to_i #3072 
  end

  def check_stylesheets_num original_name, number
    (1..number).to_a.each do |i|
      name = i == 1 ? original_name : "#{original_name}_split#{i}"
      unless get_file(name).present?
        raise "Expected asset file #{name} not present, remember that you must: 1. manually create split files as needed; 2. update split_count in corresponding layout; 3. add filename to precompile list."
      end
    end
  end

  context "every big stylesheet should be splitted for ie9" do
    [
      "app-admin",
      "app-client-admin",
      "app-external",
      "app-internal",
      "app-landing",
      "app-user-progress"
    ].each do |name|
      it "#{name}" do
        file = get_file name
        sel_number = count_selectors(file)
        stylesheets_number = sel_number / max_selectors + 1
        # p name.to_s + " " + sel_number.to_s + " " + stylesheets_number.to_s
        check_stylesheets_num name, stylesheets_number
      end
    end
  end
end
