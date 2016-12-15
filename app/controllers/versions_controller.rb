class VersionsController < ApplicationController
  load_and_authorize_resource

  SUPPORTED_KLASSES_FOR_SHOW = [
    Clinic,
    Specialist,
    Language,
    Procedure,
    Hospital,
    HealthcareProvider,
    Specialization
  ]
  def show
    @version = Version.find(params[:id])

    if @version.event == "destroy"
      # pre-change version

      item = @version.reify
    else
      # post-change version

      item = @version.next.try(:reify) || @version.item
    end

    klass = item.class
    instance_name = klass.to_s.downcase

    instance_variable_set("@#{instance_name}", item)

    @is_version = true

    if SUPPORTED_KLASSES_FOR_SHOW.include?(klass)
      render template: "#{instance_name.pluralize}/show"
    else
      redirect_to root_url, notice: "Can't show this item"
    end
  end

  def index
    @versions =
      Version.
        order('id desc').
        no_blacklist.
        paginate(page: params[:page], per_page: 300)
  end
end
