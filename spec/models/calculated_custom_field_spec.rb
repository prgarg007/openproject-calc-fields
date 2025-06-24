require 'spec_helper'

RSpec.describe CalculatedCustomField, type: :model do
  let(:custom_field) { FactoryBot.create(:work_package_custom_field) }
  let(:calculated_field) { FactoryBot.build(:calculated_custom_field, custom_field: custom_field) }

  describe 'validations' do
    it 'validates presence of formula' do
      calculated_field.formula = nil
      expect(calculated_field).not_to be_valid
      expect(calculated_field.errors[:formula]).to include("can't be blank")
    end

    it 'validates formula length' do
      calculated_field.formula = 'a' * 501
      expect(calculated_field).not_to be_valid
      expect(calculated_field.errors[:formula]).to include('is too long (maximum is 500 characters)')
    end

    it 'validates output type inclusion' do
      calculated_field.output_type = 'invalid'
      expect(calculated_field).not_to be_valid
      expect(calculated_field.errors[:output_type]).to include('is not included in the list')
    end
  end

  describe '#evaluate_for_work_package' do
    let(:work_package) { FactoryBot.create(:work_package, subject: 'Test Subject') }
    
    it 'evaluates CONCAT formula correctly' do
      calculated_field.formula = 'CONCAT({subject}, " - Done")'
      calculated_field.output_type = 'text'
      calculated_field.save!
      
      result = calculated_field.evaluate_for_work_package(work_package)
      expect(result).to eq('Test Subject - Done')
    end
  end
end