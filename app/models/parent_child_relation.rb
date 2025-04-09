class ParentChildRelation < ApplicationRecord
  # アソシエーション
  belongs_to :parent , class_name: 'User'
  belongs_to :child , class_name: 'User'

  # バリデーション
  validates :parent_id, presence: true
  validates :child_id, presence: true, uniqueness: { scope: :parent_id }
  validate :validate_parent_role
  validate :validate_child_role

  private

  def validate_parent_role
    unless parent&.parent?
      erros.add(:parent, 'must be a parent')
    end
  end

  def validate_child_role
    unless child&.child?
      errors.add(:child, 'must be a child')
    end
  end
  
end
