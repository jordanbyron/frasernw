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

    if item.respond_to?(:active_feedback_items)
      @feedback = item.active_feedback_items.build
    end

    @is_version = true

    if SUPPORTED_KLASSES_FOR_SHOW.include?(klass)
      render template: "#{instance_name.pluralize}/show"
    else
      redirect_to root_url, notice: "Can't show this item"
    end
  end

  def show_all
    @versions =
      Version.order('id desc').no_blacklist.paginate(page: params[:page], per_page: 300)
  end

  def revert
    @version = Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      if @version.item.specialization
        klass = @version.item.specialization.class.to_s.downcase.pluralize.to_sym
        @version.item.destroy
        redirect_to klass and return
      else
        redirect_to '/' and return
      end
    end
    link_name = params[:redo] == "true" ? "undo" : "redo"
    link = view_context.link_to(
      link_name,
      revert_version_path(@version.next, redo: !params[:redo]),
      method: :post
    )
    redirect_to :back, notice: "Undid #{@version.event}. #{link}"
  end

end
