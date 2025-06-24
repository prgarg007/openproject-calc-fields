class Admin::CalculatedCustomFieldsController < ApplicationController
    layout 'admin'
    
    before_action :require_admin
    before_action :find_calculated_custom_field, only: [:show, :edit, :update, :destroy]
    
    def index
      @calculated_custom_fields = CalculatedCustomField.includes(:custom_field)
                                                      .order(:created_at)
                                                      .page(params[:page])
    end
  
    def show
    end
  
    def new
      @calculated_custom_field = CalculatedCustomField.new
      @custom_fields = available_custom_fields
    end
  
    def create
      @calculated_custom_field = CalculatedCustomField.new(calculated_custom_field_params)
      @custom_fields = available_custom_fields
      
      if @calculated_custom_field.save
        mark_custom_field_as_calculated
        flash[:notice] = l(:notice_successful_create)
        redirect_to admin_calculated_custom_fields_path
      else
        render :new
      end
    end
  
    def edit
      @custom_fields = available_custom_fields
    end
  
    def update
      @custom_fields = available_custom_fields
      
      if @calculated_custom_field.update(calculated_custom_field_params)
        flash[:notice] = l(:notice_successful_update)
        redirect_to admin_calculated_custom_fields_path
      else
        render :edit
      end
    end
  
    def destroy
      @calculated_custom_field.destroy
      unmark_custom_field_as_calculated
      flash[:notice] = l(:notice_successful_delete)
      redirect_to admin_calculated_custom_fields_path
    end
  
    def preview
      formula = params[:formula]
      work_package_id = params[:work_package_id]
      output_type = params[:output_type] || 'text'
      
      if work_package_id.present? && formula.present?
        work_package = WorkPackage.find(work_package_id)
        evaluator = CalculatedFields::FormulaEvaluator.new(
          formula: formula,
          work_package: work_package,
          output_type: output_type
        )
        
        result = evaluator.evaluate
        render json: { success: true, result: result }
      else
        render json: { success: false, error: 'Missing parameters' }
      end
    rescue StandardError => e
      render json: { success: false, error: e.message }
    end
  
    private
  
    def find_calculated_custom_field
      @calculated_custom_field = CalculatedCustomField.find(params[:id])
    end
  
    def calculated_custom_field_params
      params.require(:calculated_custom_field).permit(
        :custom_field_id, :formula, :output_type, :active
      )
    end
  
    def available_custom_fields
      CustomField.where(type: 'WorkPackageCustomField')
                 .where.not(id: CalculatedCustomField.pluck(:custom_field_id))
                 .order(:name)
    end
  
    def mark_custom_field_as_calculated
      custom_field = @calculated_custom_field.custom_field
      custom_field.update(
        is_calculated: true,
        calculation_formula: @calculated_custom_field.formula,
        formula_output_type: @calculated_custom_field.output_type
      )
    end
  
    def unmark_custom_field_as_calculated
      custom_field = @calculated_custom_field.custom_field
      custom_field.update(
        is_calculated: false,
        calculation_formula: nil,
        formula_output_type: nil
      )
    end
  end