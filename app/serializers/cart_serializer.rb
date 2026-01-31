class CartSerializer < ActiveModel::Serializer
  attributes :id, :products, :total_price
  
  def products
    object.cart_items.map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.product.price,
        total_price: item.quantity * item.product.price
      }
    end
  end
end
