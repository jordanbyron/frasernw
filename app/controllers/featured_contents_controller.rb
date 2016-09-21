class FeaturedContentsController < ApplicationController
  def edit
    authorize! :edit, FeaturedContent

    if params[:division_id].present?
      @division = Division.find(params[:division_id])
    else
      @division = current_user.as_divisions.first
    end

    if (
      !current_user.as_super_admin? &&
        !(current_user.as_divisions.include? @division)
    )
      redirect_to root_url, notice: "Not allowed to edit this division."
    end

    @division.build_featured_contents!
  end

  def update
    authorize! :update, FeaturedContent
    @division = Division.find(params[:division][:id])
    if (
      !current_user.as_super_admin? &&
        !(current_user.as_divisions.include? @division)
    )
      redirect_to root_url, notice: "Not allowed to edit this division."
    elsif @division.update_attributes(params[:division])
      @division.featured_contents.where(sc_item_id: nil).destroy_all

      User.in_divisions([@division]).
        map{ |u| u.divisions.map{ |d| d.id } }.
        uniq.
        each do |division_group|
          expire_fragment "featured_content_#{division_group.join('_')}"
        end

      redirect_to root_path(division_id: @division.id),
        notice: "Successfully updated featured content."
    else
      render action: 'edit'
    end
  end
end
