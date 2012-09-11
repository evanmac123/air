module Sequenceable

  # This is used with spec/factories.rb so you can actually match the 'n' of your
  # sequence to the next id in the database
  def next_id
    self.last.nil? ? 1 : self.last.id + 1
  end

end
