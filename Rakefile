### Won't be necessary as of Rake 11.1.0 (next Rspec upgrade)
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end

Rake::Application.send :include, TempFixForRakeLastComment
###

require File.expand_path('../config/application', __FILE__)
require 'rake'
Health::Application.load_tasks
