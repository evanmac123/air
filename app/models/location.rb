class Location < ActiveRecord::Base
  belongs_to :demo
  has_many :users

  has_alphabetical_column :name

  validates_presence_of :name

  before_save :set_normalized_name_if_name_changed

  def self.name_ilike(search_term)
    normalized_term = normalize_string(search_term)
    where("normalized_name ILIKE ?", "%#{normalized_term}%")
  end

  protected

  def set_normalized_name_if_name_changed
    return unless changed.include?('name')
    set_normalized_name
  end

  def set_normalized_name
    self.normalized_name = Location.normalize_string(name)
  end

  def self.normalize_string(string)
    string.downcase.gsub(/[^[:alnum:][:space:]]/, ' ').gsub(/\s+/, ' ').strip
  end

  def self.reset_all_normalized_names!
    self.all.each do |location|
      location.send(:set_normalized_name)
      location.save!
    end
  end
end
