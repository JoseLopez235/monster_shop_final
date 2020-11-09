require 'rails_helper'

RSpec.describe Cart do
  describe 'Instance Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 2 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
      @m_user = @megan.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'test', role: 1)
      @order_1 = @m_user.orders.create!(status: "pending")
      @item = @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2)
      @discount1 = @megan.discounts.create!(discount: 5, quantity: 2)
      @discount2 = @megan.discounts.create!(discount: 10, quantity: 5)
    end

    it '.contents' do
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.add_item()' do
      @cart.add_item(@hippo.id.to_s)

      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2,
        @hippo.id.to_s => 1
        })
    end

    it '.count' do
      expect(@cart.count).to eq(3)
    end

    it '.items' do
      expect(@cart.items).to eq([@ogre, @giant])
    end

    it '.grand_total' do
      expect(@cart.grand_total).to eq(120)
    end

    it '.count_of()' do
      expect(@cart.count_of(@ogre.id)).to eq(1)
      expect(@cart.count_of(@giant.id)).to eq(2)
    end

    it '.subtotal_of()' do
      expect(@cart.subtotal_of(@ogre.id)).to eq(20)
      expect(@cart.subtotal_of(@giant.id)).to eq(100)
    end

    it '.limit_reached?()' do
      expect(@cart.limit_reached?(@ogre.id)).to eq(false)
      expect(@cart.limit_reached?(@giant.id)).to eq(true)
    end

    it '.less_item()' do
      @cart.less_item(@giant.id.to_s)

      expect(@cart.count_of(@giant.id)).to eq(1)
    end

    it ".discount?()" do
      cart = Cart.new({
        @ogre.id.to_s => 3,
        })
      item = Item.find(@item.item_id)
      expect(cart.discount?(item)).to eq(@discount1)
    end

    it ".discount?() checking with more than one discount" do
      cart = Cart.new({
        @ogre.id.to_s => 8,
        })
      item = Item.find(@item.item_id)
      expect(cart.discount?(item)).to eq(@discount2)
    end

    it ".discount" do
      cart = Cart.new({
        @ogre.id.to_s => 8,
        })
      item = Item.find(@item.item_id)

      expect(cart.subtotal_of(item.id) - cart.discount(item, cart.discount?(item))).to eq(144.0)
    end

    it ".discount for price" do
      cart = Cart.new({
        @ogre.id.to_s => 8,
        })
      item = Item.find(@item.item_id)
      expect(item.price - cart.discount(item, cart.discount?(item), true)).to eq(18.0)
    end
  end
end
