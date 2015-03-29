require 'ffi'
require_relative 'step_wrapper'

module CucumberCsteps

  TYPE_MAP = {
    'char*'       => {ffi_type: ':string', cast_op: 'to_s'},
    'const char*' => {ffi_type: ':string', cast_op: 'to_s'},
    'int'         => {ffi_type: ':int',    cast_op: 'to_i'},
    'float'       => {ffi_type: ':float',  cast_op: 'to_f'},
    'double'      => {ffi_type: ':double', cast_op: 'to_f'},
  }

  def self.load_steps(lib_name, lib_file, glob_patterns)
    Dir.glob(glob_patterns).each do |file|
      CucumberCsteps.define_steps(file, lib_name, lib_file).each do |regex, block|
        Cucumber::RbSupport::RbDsl.register_rb_step_definition(regex, block)
      end
    end
  end

  def self.define_steps(filename, library_name, library_file)
    module_name = library_name.camelize
    module_code = %Q{
      module #{module_name}
        extend FFI::Library
        ffi_lib ['#{library_name}', '#{library_file}']

        begin
          attach_function('before_scenario', [], :void)
          before_hook = proc { #{module_name}.before_scenario() }
          Cucumber::RbSupport::RbDsl.register_rb_hook('before', [], before_hook)
        rescue FFI::NotFoundError
        end

        begin
          attach_function('after_scenario', [], :void)
          after_hook = proc { #{module_name}.after_scenario() }
          Cucumber::RbSupport::RbDsl.register_rb_hook('after', [], proc { after_hook() })
        rescue FFI::NotFoundError
        end
      end
    }

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
        end
      }

      eval(attach_code)

      lambda_args = step.c_args.map do |arg|
        arg.identifier
      end.join(",")

      fun_args = step.c_args.map do |arg|
        cast_op = TYPE_MAP[arg.type][:cast_op]
        "#{arg.identifier}.#{cast_op}"
      end.join(",")

      code_block = %Q{lambda { |#{lambda_args}| 
        CucumberCsteps.try_and_catch_abort do
          #{module_name}.#{fun_name}(#{fun_args})
        end
       }}

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
