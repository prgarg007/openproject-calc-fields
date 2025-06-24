FactoryBot.define do
    factory :calculated_custom_field do
      association :custom_field, factory: :work_package_custom_field
      formula { 'CONCAT({subject}, " - ", {status})' }
      output_type { 'text' }
      active { true }
    end
  end