class User < ApplicationRecord
  # アソシエーション
  has_many :parent_relations, class_name: 'ParentChildRelation', foreign_key: 'parent_id'
  has_many :children, through: :parent_relations, source: :child

  has_one :child_relation, class_name: 'ParentChildRelation', foreign_key: 'child_id'
  has_one :parent, through: :child_relation
  
  # Devise設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 列挙型とバリデーション
  enum :role, { parent: 0, child: 1 }
  validates :role, presence: true, inclusion: { in: roles.keys.map(&:to_s) }
        

  # カスタムバリデーション
  validate :parent_cannot_have_parent, if: :parent?
  validate :child_cannot_have_children, if: :child?
  
  # ヘルパーメソッド
  def can_create_child_account?
    parent?
  end

  def can_view_child_messages?
    parent?
  end

  def can_message_parent?
    child?
  end

  private

  def parent_cannot_have_parent
    if parent.present?
      errors.add(:base, 'Parent cannot have a parent')
    end
  end

  def child_cannot_have_children
    if children.any?
      errors.add(:base, 'Child cannot have children')
    end
  end
end
