class RemoveMerchantsFromDiscounts < ActiveRecord::Migration[5.2]
  def change
    remove_reference :discounts, :merchants, foreign_key: true
  end
end
