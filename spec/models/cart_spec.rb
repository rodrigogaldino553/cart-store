require "rails_helper"

RSpec.describe Cart, type: :model do
  let(:cart) { Cart.create!(total_price: 0) }
  let(:product) { Product.create!(name: "test product", price: 10) }

  context "when validating" do
    it "validates numericality of total_price" do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe "#update_cart_total_price" do
    it "updates the total price of the cart" do
      cart.cart_items.create!(product: product, quantity: 2)
      cart.touch
      expect(cart.total_price).to eq(20)
    end
  end
  describe "mark_as_abandoned" do
    let(:cart) { create(:cart) }

    it "marks the shopping cart as abandoned if inactive for a certain time" do
      cart.update(last_interaction_at: 3.hours.ago)
      expect { cart.mark_as_abandoned }.to change { cart.abandoned? }.from(false).to(true)
    end
  end
end
