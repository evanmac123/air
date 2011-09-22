lib_path = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

%w(survey_answer survey survey_prompt survey_question survey_valid_answer).each do |module_name|
  require "#{lib_path}/#{module_name}_behavior"
end
