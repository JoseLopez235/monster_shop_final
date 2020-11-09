require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Order Show Page' do
  describe 'As a Registered User' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @sal = Merchant.create!(name: 'Sals Salamanders', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @user = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan_1@example.com', password: 'securepassword')
      @order_1 = @user.orders.create!(status: "packaged")
      @order_2 = @user.orders.create!(status: "pending")
      @order_item_1 = @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: true)
      @order_item_2 = @order_2.order_items.create!(item: @giant, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @discount = @megan.discounts.create!(discount: 5, quantity: 2)
      @discount = @megan.discounts.create!(discount: 10, quantity: 5)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'I can link from my orders to an order show page' do
      visit '/profile/orders'

      click_link @order_1.id

      expect(current_path).to eq("/profile/orders/#{@order_1.id}")
    end

    it 'I see order information on the show page' do
      3.times do
        visit item_path(@ogre)
        click_button 'Add to Cart'
      end
      visit '/cart'
      within "#checkout" do
       click_button "Check Out"
      end

      order = Order.all.last
      order_item = Order.all.last.order_items.first
      visit "/profile/orders/#{order.id}"

      expect(page).to have_content(order.id)
      expect(page).to have_content("Created On: #{order.created_at}")
      expect(page).to have_content("Updated On: #{order.updated_at}")
      expect(page).to have_content("Status: #{order.status}")
      expect(page).to have_content("#{order.count_of_items} items")
      expect(page).to have_content("Total: #{number_to_currency(order.grand_total)}")

      within "#order-item-#{order_item.id}" do
        expect(page).to have_link(order_item.item.name)
        expect(page).to have_content(order_item.item.description)
        expect(page).to have_content(order_item.quantity)
        expect(page).to have_content(order_item.price)
        expect(page).to have_content("Subtotal: $57.72")
      end

      5.times do
        visit item_path(@ogre)
        click_button 'Add to Cart'
      end
      visit '/cart'
      within "#checkout" do
       click_button "Check Out"
      end

      order = Order.all.last
      order_item = Order.all.last.order_items.first
      visit "/profile/orders/#{order.id}"
      within "#order-item-#{order_item.id}" do
        expect(page).to have_link(order_item.item.name)
        expect(page).to have_content(order_item.item.description)
        expect(page).to have_content(order_item.quantity)
        expect(page).to have_content(order_item.price)
        expect(page).to have_content("Subtotal: $91.15")
      end
    end

    it 'I see a link to cancel an order, only on a pending order show page' do
      visit "/profile/orders/#{@order_1.id}"

      expect(page).to_not have_button('Cancel Order')

      visit "/profile/orders/#{@order_2.id}"

      expect(page).to have_button('Cancel Order')
    end

    it 'I can cancel an order to return its contents to the items inventory' do
      visit "/profile/orders/#{@order_2.id}"

      click_button 'Cancel Order'

      expect(current_path).to eq("/profile/orders/#{@order_2.id}")
      expect(page).to have_content("Status: cancelled")

      @giant.reload
      @ogre.reload
      @order_item_2.reload
      @order_item_3.reload

      expect(@order_item_2.fulfilled).to eq(false)
      expect(@order_item_3.fulfilled).to eq(false)
      expect(@giant.inventory).to eq(5)
      expect(@ogre.inventory).to eq(7)
    end

    it "Will show the grand total with the discounts" do
      5.times do
        visit item_path(@ogre)
        click_button 'Add to Cart'
      end
      visit '/cart'
      within "#checkout" do
       click_button "Check Out"
      end

      order = Order.all.last
      order_item = Order.all.last.order_items.first
      visit "/profile/orders/#{order.id}"

      expect(order.grand_total).to eq(91.15)
    end

    it "Will show the grand total without the discounts" do
      1.times do
        visit item_path(@ogre)
        click_button 'Add to Cart'
      end
      visit '/cart'
      within "#checkout" do
       click_button "Check Out"
      end

      order = Order.all.last
      order_item = Order.all.last.order_items.first
      visit "/profile/orders/#{order.id}"

      expect(order.grand_total).to eq(20.25)
    end
  end
end
