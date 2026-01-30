class CartItem < ApplicationRecord
  belongs_to :cart, touch: true
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }
  
  before_validation :update_item_total_price
  
  private
  
  def update_item_total_price
    self.total_price = product.price * quantity
  end
end
