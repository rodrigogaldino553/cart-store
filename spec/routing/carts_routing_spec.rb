require "rails_helper"

RSpec.describe Api::V1::CartsController, type: :routing do
  describe "routes" do
    it "routes to #show" do
      expect(get: "/api/v1/cart").to route_to("api/v1/carts#show")
    end

    it "routes to #create" do
      expect(post: "/api/v1/cart").to route_to("api/v1/carts#create")
    end

    it "routes to #add_item via PUT" do
      expect(put: "/api/v1/cart/add_item").to route_to("api/v1/carts#update")
    end
  end
end
