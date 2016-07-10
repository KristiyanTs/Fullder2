# == Schema Information
#
# Table name: orders
#
#  id              :integer          not null, primary key
#  order_status_id :integer
#  subtotal        :decimal(, )
#  tax             :decimal(, )
#  shipping        :decimal(, )
#  tip             :decimal(, )
#  total           :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_orders_on_order_status_id  (order_status_id)
#
# Foreign Keys
#
#  fk_rails_7a22cf8b0e  (order_status_id => order_statuses.id)
#

class Order < ActiveRecord::Base
  belongs_to :order_status

  has_many :order_items, dependent: :destroy

  before_create :set_order_status
  before_save :update_subtotal

  def subtotal
    order_items.collect { |oi| oi.valid? ? (oi.quantity * oi.unit_price) : 0 }.sum
  end

  private

  def set_order_status
    self.order_status_id = 1
  end

  def update_subtotal
    self[:subtotal] = subtotal
  end
end
