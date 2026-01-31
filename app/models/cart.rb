class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  after_touch :update_cart_total_price

  enum status: { active: 0, abandoned: 1 }

  scope :ready_to_abandon, -> {
    where(status: :active)
      .where('last_interaction_at < ?', 3.hours.ago)
  }
  
  scope :ready_to_delete, -> {
    where(status: :abandoned)
      .where('abandoned_at < ?', 7.days.ago)
  }
  
  def mark_as_abandoned!
    update(status: :abandoned, abandoned_at: Time.current)
  end
  
  def touch_interaction
    update_column(:last_interaction_at, Time.current)
  end
  
  private 
  
  def update_cart_total_price
    update(total_price: cart_items.includes(:product).sum(&:total_price))
  end
end
