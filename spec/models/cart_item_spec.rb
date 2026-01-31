require "rails_helper"

RSpec.describe CartItem, type: :model do
  let(:cart) { Cart.create!(total_price: 0) }
  let(:product) { Product.create!(name: "test product", price: 10) }

  context "when validating" do
    it "validates numericality of quantity" do
      cart_item = described_class.new(cart: cart, product: product, quantity: 0)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than or equal to 1")
    end
  end

  describe "#update_item_total_price" do
    it "updates the total price of the cart item" do
      cart_item = described_class.new(cart: cart, product: product, quantity: 2)
      cart_item.save
      expect(cart_item.total_price).to eq(20)
    end
  end
end
