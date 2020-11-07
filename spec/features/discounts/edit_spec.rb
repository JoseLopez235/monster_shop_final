require "rails_helper"

describe "As A merchant" do
  before :each do
    @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
    @m_user = @megan.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'test', role: 1)
    @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
    @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )

    @order_1 = @m_user.orders.create!(status: "pending")
    @order_2 = @m_user.orders.create!(status: "pending")
    @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2)
    @order_2.order_items.create!(item: @giant, price: @giant.price, quantity: 2)
    @discount = @megan.discounts.create!(discount: 5.0, quantity: 10)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)

  end

  describe "If I go to the merchant dashboard I should see a link to edit a discount" do
    it "When I click the link the field tags should be filled with the current information" do
      visit "/merchant"

      within "#discounts" do
        click_link "Edit Discount"
      end
      expect(current_path).to eq("/merchant/discounts/#{@discount.id}/edit")
      expect(find_field('discount').value).to eq("#{@discount.discount}")
      expect(find_field('quantity').value).to eq("#{@discount.quantity}")
    end

    it "Allows me to change the info and when I click submit the discount should be updated" do
      visit "/merchant/discounts/#{@discount.id}/edit"

      fill_in 'Discount', with: 10.0
      fill_in 'Quantity', with: 100
      click_button 'Update Discount'

      @discount.reload
      save_and_open_page
      expect(current_path).to eq('/merchant')
      expect(page).to have_content("10% off #{@discount.quantity} items or more")
    end
  end
end
