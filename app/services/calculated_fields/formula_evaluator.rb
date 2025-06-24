module CalculatedFields
    class FormulaEvaluator
      def initialize(formula:, work_package:, output_type: 'text')
        @formula = formula
        @work_package = work_package
        @output_type = output_type
      end
  
      def evaluate
        substituted_formula = substitute_field_values
        result = evaluate_formula(substituted_formula)
        convert_output(result)
      end
  
      private
  
      attr_reader :formula, :work_package, :output_type
  
      def substitute_field_values
        substituted = formula.dup
        
        # Replace field placeholders with actual values
        substituted.gsub!(/\{([^}]+)\}/) do |match|
          field_name = $1
          value = get_field_value(field_name)
          escape_value(value)
        end
        
        substituted
      end
  
      def get_field_value(field_name)
        case field_name
        when 'subject'
          work_package.subject
        when 'description'
          work_package.description
        when 'status'
          work_package.status&.name
        when 'priority'
          work_package.priority&.name
        when 'assigned_to'
          work_package.assigned_to&.name
        when /^cf_(\d+)$/
          custom_field_id = $1
          work_package.custom_field_value(custom_field_id)
        else
          ''
        end
      end
  
      def escape_value(value)
        return '""' if value.nil?
        return value.to_s if value.is_a?(Numeric)
        "\"#{value.to_s.gsub('"', '""')}\""
      end
  
      def evaluate_formula(formula_string)
        # Simple formula evaluator
        # In production, consider using a more robust formula parser
        
        # Handle CONCAT function
        if formula_string.match(/CONCAT\s*\(/i)
          return evaluate_concat(formula_string)
        end
        
        # Handle IF function
        if formula_string.match(/IF\s*\(/i)
          return evaluate_if(formula_string)
        end
        
        # Handle string functions
        %w[LOWER UPPER TRIM].each do |func|
          if formula_string.match(/#{func}\s*\(/i)
            return evaluate_string_function(formula_string, func)
          end
        end
        
        # Handle LEN function
        if formula_string.match(/LEN\s*\(/i)
          return evaluate_len(formula_string)
        end
        
        # Basic arithmetic evaluation for numbers
        if output_type == 'number'
          return evaluate_arithmetic(formula_string)
        end
        
        formula_string
      end
  
      def evaluate_concat(formula_string)
        # Extract arguments from CONCAT(arg1, arg2, ...)
        match = formula_string.match(/CONCAT\s*\((.*)\)/mi)
        return '' unless match
        
        args_string = match[1]
        args = parse_function_arguments(args_string)
        
        args.map { |arg| evaluate_argument(arg) }.join
      end
  
      def evaluate_if(formula_string)
        # IF(condition, true_value, false_value)
        match = formula_string.match(/IF\s*\((.*)\)/mi)
        return '' unless match
        
        args_string = match[1]
        args = parse_function_arguments(args_string)
        return '' unless args.length == 3
        
        condition = evaluate_condition(args[0])
        if condition
          evaluate_argument(args[1])
        else
          evaluate_argument(args[2])
        end
      end
  
      def evaluate_string_function(formula_string, function_name)
        match = formula_string.match(/#{function_name}\s*\((.*)\)/mi)
        return '' unless match
        
        arg = match[1].strip
        value = evaluate_argument(arg)
        
        case function_name.upcase
        when 'LOWER'
          value.to_s.downcase
        when 'UPPER'
          value.to_s.upcase
        when 'TRIM'
          value.to_s.strip
        else
          value
        end
      end
  
      def evaluate_len(formula_string)
        match = formula_string.match(/LEN\s*\((.*)\)/mi)
        return 0 unless match
        
        arg = match[1].strip
        value = evaluate_argument(arg)
        value.to_s.length
      end
  
      def evaluate_arithmetic(formula_string)
        # Simple arithmetic evaluation
        # Remove spaces and evaluate basic expressions
        sanitized = formula_string.gsub(/[^\d+\-*/().]/, '')
        return 0 if sanitized.empty?
        
        begin
          eval(sanitized).to_f
        rescue StandardError
          0
        end
      end
  
      def parse_function_arguments(args_string)
        args = []
        current_arg = ''
        paren_depth = 0
        in_quotes = false
        quote_char = nil
        
        args_string.each_char do |char|
          case char
          when '"', "'"
            if in_quotes && char == quote_char
              in_quotes = false
              quote_char = nil
            elsif !in_quotes
              in_quotes = true
              quote_char = char
            end
            current_arg += char
          when '('
            paren_depth += 1 unless in_quotes
            current_arg += char
          when ')'
            paren_depth -= 1 unless in_quotes
            current_arg += char
          when ','
            if !in_quotes && paren_depth == 0
              args << current_arg.strip
              current_arg = ''
            else
              current_arg += char
            end
          else
            current_arg += char
          end
        end
        
        args << current_arg.strip if current_arg.present?
        args
      end
  
      def evaluate_argument(arg)
        arg = arg.strip
        
        # Remove surrounding quotes
        if (arg.start_with?('"') && arg.end_with?('"')) ||
           (arg.start_with?("'") && arg.end_with?("'"))
          return arg[1..-2]
        end
        
        # Try to convert to number
        if arg.match?(/^\d+(\.\d+)?$/)
          return arg.include?('.') ? arg.to_f : arg.to_i
        end
        
        arg
      end
  
      def evaluate_condition(condition_string)
        # Simple condition evaluation
        condition_string = condition_string.strip
        
        # Handle simple comparisons
        if condition_string.match(/(.+)\s*(==|!=|>|<|>=|<=)\s*(.+)/)
          left = evaluate_argument($1.strip)
          operator = $2
          right = evaluate_argument($3.strip)
          
          case operator
          when '=='
            left == right
          when '!='
            left != right
          when '>'
            left.to_f > right.to_f
          when '<'
            left.to_f < right.to_f
          when '>='
            left.to_f >= right.to_f
          when '<='
            left.to_f <= right.to_f
          else
            false
          end
        else
          # Treat as boolean value
          value = evaluate_argument(condition_string)
          !value.to_s.empty? && value.to_s.downcase != 'false'
        end
      end
  
      def convert_output(result)
        case output_type
        when 'number'
          result.to_f
        when 'boolean'
          !!result && result.to_s.downcase != 'false'
        else
          result.to_s
        end
      end
    end
  end