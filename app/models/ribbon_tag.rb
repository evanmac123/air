# frozen_string_literal: true

class RibbonTag < ActiveRecord::Base
  belongs_to :demo
  has_many :tiles

  validates_presence_of :name, allow_blank: false, message: "name can't be blank"
  validates_presence_of :color, allow_blank: false, message: "color can't be blank"
end
