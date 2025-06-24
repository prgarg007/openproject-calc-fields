class CalculatedCustomField < ApplicationRecord
    belongs_to :custom_field
    
    validates :formula, presence: true, length: { maximum: 500 }
    validates :output_type, inclusion: { in: %w[text number boolean] }
    
    before_save :parse_formula
    after_save :update_dependent_work_packages
    
    scope :active, -> { where(active: true) }
    
    OUTPUT_TYPES = {
      'text' => 'Text',
      'number' => 'Number', 
      'boolean' => 'Boolean'
    }.freeze
  
    ALLOWED_FUNCTIONS = %w[
      CONCAT IF LOWER UPPER LEN TRIM LEFT RIGHT MID
      ROUND ABS MIN MAX SUM AVERAGE
    ].freeze
  
    def self.for_custom_field(custom_field_id)
      find_by(custom_field_id: custom_field_id)
    end
  
    def evaluate_for_work_package(work_package)
      return nil unless active? && parsed_formula.present?
      
      CalculatedFields::FormulaEvaluator.new(
        formula: parsed_formula,
        work_package: work_package,
        output_type: output_type
      ).evaluate
    rescue StandardError => e
      Rails.logger.error "Error evaluating calculated field #{id}: #{e.message}"
      nil
    end
  
    private
  
    def parse_formula
      self.parsed_formula = CalculatedFields::FormulaValidator.new(formula).parse
      self.referenced_fields = extract_referenced_fields
    rescue CalculatedFields::FormulaValidator::InvalidFormulaError => e
      errors.add(:formula, e.message)
      throw :abort
    end
  
    def extract_referenced_fields
      return [] unless parsed_formula.present?
      
      # Extract field references from parsed formula
      fields = []
      parsed_formula.scan(/\{([^}]+)\}/) do |match|
        field_name = match.first
        if field_name.start_with?('cf_')
          fields << field_name
        else
          # Standard field reference
          fields << field_name
        end
      end
      fields.uniq
    end
  
    def update_dependent_work_packages
      return unless saved_change_to_formula? || saved_change_to_active?
      
      CalculatedFields::FieldUpdaterJob.perform_later(custom_field_id)
    end
  end