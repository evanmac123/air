class SuggestedTask < ActiveRecord::Base
  belongs_to :demo
  has_and_belongs_to_many :prerequisites, :class_name => "SuggestedTask", :join_table => :prerequisites, :association_foreign_key => :prerequisite_id

  def self.alphabetical
    order(:name)
  end
end
