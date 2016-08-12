# frozen_string_literal: true
# == Schema Information
#
# Table name: order_items
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  order_id    :integer
#  size_id     :integer
#  unit_price  :decimal(, )
#  quantity    :integer
#  total_price :decimal(, )
#  demands     :string
#  received_at :datetime
#  ready_at    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_order_items_on_order_id    (order_id)
#  index_order_items_on_product_id  (product_id)
#  index_order_items_on_size_id     (size_id)
#
# Foreign Keys
#
#  fk_rails_28971b9eb6  (size_id => sizes.id)
#  fk_rails_e3cb28f071  (order_id => orders.id)
#  fk_rails_f1a29ddd47  (product_id => products.id)
#

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :size

  has_many :groups_order_items, dependent: :destroy
  has_many :groups, through: :groups_order_items
  accepts_nested_attributes_for :groups

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :product_present
  validate :order_present
  validate :size_selected
  # validate :options_allowed?

  before_save :finalize

  def unit_price
    if persisted?
      self[:unit_price]
    else
      size_id.nil? ? product.price : product.price + product.sizes.find(size_id).price
    end
  end

  def total_price
    unit_price * quantity
  end

  private

  def product_present
    errors.add(:product, 'is not valid or is not active.') if product.nil?
  end

  def size_selected
    self[:size_id] = product.sizes.first.id if product.sizes.any? && size_id.nil?
  end

  def order_present
    errors.add(:order, 'is not a valid order.') if order.nil?
  end

  def finalize
    self[:unit_price] = unit_price
    self[:total_price] = quantity * self[:unit_price]
  end

  def options_allowed?
    groups.any?{|gr| gr.maximum > gr.options.count}
  end
end
