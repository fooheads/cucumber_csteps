require 'ffi'
require_relative 'step_wrapper'

require 'cucumber/rb_support/snippet.rb'

# Hack to output C step definitions
module Cucumber
  module RbSupport
    module Snippet
      class Regexp < BaseSnippet
        def initialize(code_keyword, pattern, multiline_argument)
          super(code_keyword.upcase, pattern, multiline_argument)
        end

        def do_block
          do_block = ""
          do_block << "(#{arguments}) {\n"
          #multiline_argument.append_comment_to(do_block)
          do_block << "  //pending(); // Write code here that turns the phrase above into concrete actions\n"
          do_block << "}"
          do_block
        end

        def arguments
          block_args = (0...number_of_arguments).map { |n| "some_t arg#{n+1}" }
          block_args.empty? ? "" : "#{block_args.join(", ")}"
        end

        def typed_pattern
          @code_keyword = @code_keyword.upcase
          "(\"^#{pattern}$\")"
        end

        def self.description
          "Snippets with parentheses"
        end
      end
    end
  end
end


module CucumberCsteps

  TYPE_MAP = {
    'char*'       => {ffi_type: ':string', cast_op: 'to_s'},
    'const char*' => {ffi_type: ':string', cast_op: 'to_s'},
    'int'         => {ffi_type: ':int',    cast_op: 'to_i'},
    'float'       => {ffi_type: ':float',  cast_op: 'to_f'},
    'double'      => {ffi_type: ':double', cast_op: 'to_f'},
  }

  def self.define_steps(filename, library_name, library_file)
    module_name = library_name.camelize
    module_code = %Q{
      module #{module_name}
        extend FFI::Library
        ffi_lib ['#{library_name}', '#{library_file}']

        #attach_function('mu_assert_get_last_error', [], :string)
        #attach_function('mu_assert_clear_last_error', [], :void)

        #attach_function('before_scenario', [], :string)
        #attach_function('after_scenario', [], :string)
      end
    }
    #puts module_code
    eval(module_code)

    step_prefix = find_step_prefix(filename)
    step_definitions = find_step_definitions(filename)
    step_definitions.map do |step_definition, line_number|
      step = parse_cstep(step_definition)
      fun_name = "#{step_prefix}#{line_number}".to_sym
      args = step.c_args.map { |arg| TYPE_MAP[arg.type][:ffi_type] }.join(",")

      attach_code = %Q{
        module #{module_name}
          #{fun_name} = attach_function('#{fun_name}', [#{args}], :void)
          puts "hola:"
          puts #{fun_name}.class
        end
      }
      #puts attach_code
      eval(attach_code)

      lambda_args = step.c_args.map do |arg|
        arg.identifier
      end.join(",")

      fun_args = step.c_args.map do |arg|
        cast_op = TYPE_MAP[arg.type][:cast_op]
        "#{arg.identifier}.#{cast_op}"
      end.join(",")

      code_block = %Q{lambda { |#{lambda_args}| 
        ##{module_name}.mu_assert_clear_last_error
        CucumberCsteps.try_and_catch_abort do
          #{module_name}.#{fun_name}(#{fun_args})
        end
        #last_error = #{module_name}.mu_assert_get_last_error
        #if not last_error.nil? and not last_error.empty?
        #  fail(last_error)
        #end
       }}
      #puts code_block

      [step.regex, eval(code_block) ]
    end
  end

private

  def self.find_step_prefix(filename)
    step_prefix_regex = /#define\s+STEP_PREFIX\s+(\w+)/
    code = File.read(filename)

    prefixes = code.lines.select { |l| l =~ step_prefix_regex }
    raise "Step file '#{filename}' contains #{prefixes.size} STEP_PREFIX definitions." if prefixes.size != 1
  
    prefixes.first.match(step_prefix_regex)[1]
  end

  def self.find_step_definitions(filename)
    step_regex = /^\s*(GIVEN|WHEN|THEN)\s*(.*)/
    code = File.read(filename)

    matching_lines = []
    code.lines.each_with_index do |line, line_number|
      if line.match(step_regex)
        matching_lines << [line, line_number + 1]
      end
    end

    matching_lines
  end

end
