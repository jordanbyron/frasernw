class ScItemsController < ApplicationController
  include ScCategoriesHelper
  load_and_authorize_resource
  before_filter :authorize_division_for_user, only: :index

  def index
    @division = Division.find(params[:id])
  end

  def show
    @sc_item = ScItem.find(params[:id])
    @division = current_user.as_divisions.first
    @borrow_url = borrow_sc_item_path(@sc_item)
  end

  def new
    @sc_item = ScItem.new
    new_sc_item_preload
  end

  def create
    @sc_item = ScItem.new(params[:sc_item])
    params[:specialization] = {} if params[:specialization].blank?
    params[:procedure_specialization] =
      {} if params[:procedure_specialization].blank?
    if @sc_item.save
      params[:specialization].each do |specialization_id, set|
        @sc_item.
          sc_item_specializations.
          create(specialization_id: specialization_id)
      end
      params[:procedure_specialization].each do |ps_id, set|
        specialization = ProcedureSpecialization.find(ps_id).specialization
        sc_item_specialization = ScItemSpecialization.find_by(
          sc_item_id: @sc_item.id,
          specialization_id: specialization.id
        )
        if sc_item_specialization.present?
          ScItemSpecializationProcedureSpecialization.create(
            sc_item_specialization_id: sc_item_specialization.id,
            procedure_specialization_id: ps_id
          )
        end
      end
      Subscription::MailImmediateNotifications.call(
        klass_name: "ScItem",
        id: @sc_item.id,
        delay: true
      )
      FulfillDivisionalScItemSubscriptions.call(sc_item: @sc_item)
      redirect_to sc_item_path(@sc_item),
        notice: "Successfully created content item."
    else
      new_sc_item_preload
      render action: 'new'
    end
  end

  def edit
    @sc_item = ScItem.find(params[:id])
    set_form_variables!(@sc_item)
  end

  def update
    @sc_item = ScItem.find(params[:id])
    params[:specialization] = {} if params[:specialization].blank?
    params[:procedure_specialization] =
      {} if params[:procedure_specialization].blank?
    if @sc_item.update_attributes(params[:sc_item])
      @sc_item.sc_item_specializations.each do |sis|
        #remove existing specializations that no longer exist
        if !params[:specialization].include? sis.specialization_id
          ScItemSpecialization.destroy(sis.id)
        end
      end
      #DevNote: ^^potentially dangerous use of destroy
      params[:specialization].each do |specialization_id, set|
        #add new specializations
        ScItemSpecialization.find_or_create_by(
          sc_item_id: @sc_item.id,
          specialization_id: specialization_id
        )
      end
      @sc_item.sc_item_specialization_procedure_specializations.each do |sisps|
        #remove existing procedure specializations that no longer exist
        if (
          !params[:procedure_specialization].
            include? sisps.procedure_specialization_id
        )
          ScItemSpecializationProcedureSpecialization.destroy(sisps.id)
        end
      end
      #DevNote: ^^potentially dangerous use of destroy
      params[:procedure_specialization].each do |ps_id, set|
        #add new procedure specializations
        specialization = ProcedureSpecialization.find(ps_id).specialization
        sc_item_specialization = ScItemSpecialization.find_by(
          sc_item_id: @sc_item.id,
          specialization_id: specialization.id
        )
        if sc_item_specialization.present?
          #parent specialization was checked off
          ScItemSpecializationProcedureSpecialization.find_or_create_by(
            sc_item_specialization_id: sc_item_specialization.id,
            procedure_specialization_id: ps_id
          )
        end
      end
      redirect_to @sc_item, notice: "Successfully updated content item."
    else
      set_form_variables!(@sc_item)
      render action: 'edit'
    end
  end

  def destroy
    @sc_item = ScItem.find(params[:id])
    @sc_item.destroy
    redirect_to sc_items_url, notice: "Successfully deleted content item."
  end

  def borrow
    @sc_item = ScItem.find(params[:id])
    authorize! :borrow, @sc_item
    @division = Division.find(params[:division_id])

    success = params[:is_borrowed].present? &&
      @sc_item.present? &&
      @division.present? &&
      can?(:update, @sc_item) &&
      UpdateScItemBorrowing.call(
        division_id: @division.id,
        sc_item: @sc_item,
        is_borrowed: params[:is_borrowed].to_b
      )

    notice = begin
      if success
        if params[:is_borrowed].to_b
          "Now displaying this item in #{@division.name}"
        else
          "No longer displaying this item in #{@division.name}"
        end
      else
        "Unable to complete your request"
      end
    end

    redirect_to sc_item_path(@sc_item), notice: notice
  end

  def bulk_borrow
    @sc_items = ScItem.find(params[:item_ids])
    authorize! :bulk_borrow, ScItem
    @division = Division.find(params[:division_id])

    successful_items = @sc_items.select do |sc_item|
      can?(:update, sc_item) &&
      UpdateScItemBorrowing.call(
        division_id: @division.id,
        sc_item: sc_item,
        is_borrowed: true
      )
    end

    notice = "Now displaying #{successful_items.map(&:title).to_sentence} " +
      "in #{@division.name}."
    redirect_to borrowable_content_items(@division), notice: notice
  end

  private

  def set_form_variables!(sc_item)
    @has_specializations = sc_item.specializations.map{ |s| s.id }
    @has_procedure_specializations =
      sc_item.procedure_specializations.map{ |ps| ps.id }
    @hierarchy = ancestry_options_limited(
      ScCategory.unscoped.arrange(order: 'name'),
      nil
    )
  end

  def authorize_division_for_user
    if !(
      current_user.as_super_admin? ||
        (current_user.as_divisions.include? Division.find(params[:id]))
    )
      redirect_to root_url, notice: "You are not allowed to access this page"
    end
  end

  def new_sc_item_preload
    @has_specializations = []
    @has_procedure_specializations = []
    @hierarchy = ancestry_options_limited(
      ScCategory.unscoped.arrange(order: 'name'),
      nil
    )
  end

end
