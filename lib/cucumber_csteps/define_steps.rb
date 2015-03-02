require 'ffi'

module CucumberCsteps

  TYPE_MAP = {
    'char*'       => {ffi_type: ':string', cast_op: 'to_s'},
    'const char*' => {ffi_type: ':string', cast_op: 'to_s'},
    'int'         => {ffi_type: ':int',    cast_op: 'to_i'},
    'float'       => {ffi_type: ':float',  cast_op: 'to_f'},
    'double'      => {ffi_type: ':double', cast_op: 'to_f'},
  }

  def self.define_steps(filename, library_name)
    module_name = library_name.camelize
    m = eval(%Q{
      module #{module_name}
        extend FFI::Library
        ffi_lib '#{library_name}'
      end
    }).first
    step_prefix = find_step_prefix(filename)
    step_definitions = find_step_definitions(filename)
    step_definitions.map do |step_definition, line_number|
      step = parse_cstep(step_definition)
      fun_name = "#{step_prefix}#{line_number}".to_sym
      args = step.c_args.map { |arg| TYPE_MAP[arg.type][:ffi_type] }.join(",")

      attach_code = %Q{
        module #{module_name}
          attach_function('#{fun_name}', [#{args}], :string)
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

      code_block = "lambda { |#{lambda_args}| #{module_name}.#{fun_name}(#{fun_args}) }"
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
