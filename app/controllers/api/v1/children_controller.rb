class Api::V1::ChildrenController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_parent!

  def create
    # 親のメールアドレスから子供のメールアドレスを生成
    child_email = generate_child_email(current_user.email)

    child_user = User.new(
      child_params.merge(
        email: child_email,
        role: 'child'
      )
    )

    ActiveRecord::Base.transaction do
      if child_user.save
        relation = current_user.parent_relations.create!(child: child_user)
        render json: {
          message: 'Child account created successfully',
          child: {
            id: child_user.id,
            email: child_user.email,
            role: child_user.role
          }
        } , status: :created
      else
        render json: { errors: child_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def child_params
    params.require(:child).permit(:email, :password, :password_confirmation)
  end

  def generate_child_email(parent_email)
    base_name = parent_email.split('@').first
    domain = parent_email.split('@').last
    timestamp = Time.current.strftime('%Y%m%d%H%M%S')
    "#{base_name}+child#{timestamp}@#{domain}"
  end

  def authorize_parent!
    unless current_user.parent?
      render json: { error: '親権限が必要です' }, status: :forbidden
    end
  end
end
