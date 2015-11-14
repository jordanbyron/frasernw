class SecretTokensController < ApplicationController
  def create
    authorize! :create, SecretToken

    raise unless ["Specialist", "Clinic"].include?(params[:accessible_type])
    accessible = params[:accessible_type].constantize.find(params[:accessible_id])
    raise unless accessible.present? && can?(:edit, accessible)
    raise unless params[:recipient].present?

    token = SecretToken.create(params.slice(
      :accessible_type,
      :accessible_id,
      :recipient
    ).merge(
      token: SecureRandom.hex(16),
      creator_id: current_user.id
    ))

    render json: {
      link: token.as_hash(request.host, current_user)
    }
  end

  def destroy
    authorize! :destroy, SecretToken

    token = SecretToken.find(params[:id])
    raise "Not allowed" unless token.expirable_by?(current_user)

    token.update_attributes(expired: true)

    render nothing: true, status: 200
  end
end
