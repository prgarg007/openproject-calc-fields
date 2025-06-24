module CalculatedFields
    class FormulaValidator
      class InvalidFormulaError < StandardError; end
  
      ALLOWED_FUNCTIONS = %w[
        CONCAT IF LOWER UPPER LEN TRIM LEFT RIGHT MID
        ROUND ABS MIN MAX SUM AVERAGE
      ].freeze
  
      DANGEROUS_PATTERNS = [
        /system\s*\(/i,
        /exec\s*\(/i,
        /eval\s*\(/i,
        /`.*`/,
        /\$\w+/,
        /__.*__/
      ].freeze
  
      def initialize(formula)
        @formula = formula.to_s.strip
      end
  
      def parse
        validate_security
        validate_syntax
        normalize_formula
      end
  
      private
  
      attr_reader :formula
  
      def validate_security
        DANGEROUS_PATTERNS.each do |pattern|
          if formula.match?(pattern)
            raise InvalidFormulaError, "Formula contains potentially dangerous code"
          end
        end
      end
  
      def validate_syntax
        # Check for balanced parentheses
        paren_count = 0
        formula.each_char do |char|
          paren_count += 1 if char == '('
          paren_count -= 1 if char == ')'
          raise InvalidFormulaError, "Unbalanced parentheses" if paren_count < 0
        end
        raise InvalidFormulaError, "Unbalanced parentheses" if paren_count != 0
  
        # Validate function names
        function_matches = formula.scan(/(\w+)\s*\(/i)
        function_matches.each do |match|
          function_name = match.first.upcase
          unless ALLOWED_FUNCTIONS.include?(function_name)
            raise InvalidFormulaError, "Function '#{function_name}' is not allowed"
          end
        end
      end
  
      def normalize_formula
        # Convert field references to standardized format
        normalized = formula.dup
        
        # Replace field names with placeholders
        normalized.gsub!(/\b(subject|description|status|priority|assigned_to)\b/i) do |match|
          "{#{match.downcase}}"
        end
        
        # Replace custom field references
        normalized.gsub!(/\bcf_(\d+)\b/i) do |match|
          "{#{match.downcase}}"
        end
        
        normalized
      end
    end
  end