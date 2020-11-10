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
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
  end

  it "If I go to the discount page, I should be able to fill out a form and add a new discount" do
    visit "/merchant/discounts"

    fill_in 'Discount', with: 5.0
    fill_in 'Quantity', with: 10
    click_button 'Create Discount'

    expect(current_path).to eq('/merchant')

    expect(page).to have_content("5% off 10 items or more")
  end

  it "Should fail if theres missing information" do
    visit "/merchant/discounts"

    fill_in 'Quantity', with: 10
    click_button 'Create Discount'

    expect(current_path).to eq('/merchant/discounts')
    expect(page).to have_content("Discount can't be blank")
  end
end
