class Discount < ApplicationRecord
  validates_presence_of :discount, :quantity

  belongs_to :merchant
end
