require "rails_helper"

RSpec.describe "Api::V1::Carts", type: :request do
  let(:product) { Product.create!(name: "A product", price: 10) }
  let(:cart) { Cart.create!(total_price: 0) }

  before do
    allow_any_instance_of(Api::V1::CartsController).to receive(:session).and_return({ cart_id: cart.id })
  end

  describe "GET /api/v1/cart" do
    it "returns a not found response when cart is not in session" do
      allow_any_instance_of(Api::V1::CartsController).to receive(:session).and_return({})
      get api_v1_cart_url, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "renders a successful response when exists" do
      get api_v1_cart_url, as: :json
      expect(response).to be_successful
    end

    it "renders a not found response for an empty cart" do
      empty_cart = Cart.create!(total_price: 0)
      allow_any_instance_of(Api::V1::CartsController).to receive(:session).and_return({ cart_id: empty_cart.id })
      get api_v1_cart_url, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /api/v1/cart" do
    context "with valid parameters" do
      it "creates a new cart and adds a product to it" do
        allow_any_instance_of(Api::V1::CartsController).to receive(:session).and_return({})
        expect {
          post api_v1_cart_url, params: {product_id: product.id}, as: :json
        }.to change(Cart, :count).by(1).and change(CartItem, :count).by(1)
      end

      it "adds a product to an existing cart" do
        post api_v1_cart_url, params: {product_id: product.id}, as: :json
        expect(response).to be_successful
        expect(cart.cart_items.count).to eq(1)
      end
    end

    context "with invalid parameters" do
      it "returns a not found response when product is not found" do
        post api_v1_cart_url, params: {product_id: "invalid"}, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "put /api/v1/cart" do
    it "updates the quantity of a product in the cart" do
      cart_item = cart.cart_items.create!(product: product, quantity: 1)
      put api_v1_cart_add_item_url, params: {product_id: product.id, quantity: 2}, as: :json
      expect(response).to be_successful
      cart_item.reload
      expect(cart_item.quantity).to eq(3)
    end

    it "returns a not found response when cart item is not found" do
      put api_v1_cart_add_item_url, params: {product_id: "invalid"}, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/cart" do
    it "removes a product from the cart" do
      cart.cart_items.create!(product: product, quantity: 1)
      delete api_v1_cart_url, params: {product_id: product.id}, as: :json
      expect(response).to be_successful
      expect(cart.cart_items.count).to eq(0)
    end

    it "returns a not found response when the cart is empty" do
      delete api_v1_cart_url, params: {product_id: product.id}, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "returns a not found response when cart item is not found" do
      cart.cart_items.create!(product: product, quantity: 1)
      delete api_v1_cart_url, params: {product_id: "invalid"}, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end