require 'parslet'
require 'active_support/core_ext/string'

module CucumberCsteps

  def self.parse_cstep(s)
    tree = CStepParser.new.parse(s)
    CStepTransform.new.apply(tree)
  end

  class CStep < Struct.new(:keyword, :regex, :c_args)
  end

  class CArg < Struct.new(:type, :identifier)
  end

  class CStepParser < Parslet::Parser
     # Single character rules
    rule(:lparen)             { str('(') >> space? }
    rule(:rparen)             { str(')') >> space? }
    rule(:comma)              { str(',') >> space? }

    rule(:space)              { match('\s').repeat(1) }
    rule(:space?)             { space.maybe }

    rule(:keyword)            { (str('GIVEN') | str('WHEN') | str('THEN')).as(:keyword) >> space? }
    rule(:anything)           { inner_paren_group | match('[^()]').repeat(1) }
    rule(:inner_paren_group)  { lparen >> anything.repeat(1) >> rparen } 
    rule(:paren_group)        { lparen >> anything.repeat(1).as(:regex) >> rparen } 

    rule(:c_identifier)       { match('[^(),]').repeat(1) }
    rule(:primitive_type)     { (match('const char\s*\*') | str('int') | str('long')).as(:c_type) >> space? }
    rule(:c_type)             { primitive_type }
    rule(:c_arg)              { c_type >> c_identifier.as(:c_identifier) } 
    rule(:c_args)             { lparen >> (c_arg.as(:c_arg) >> (comma >> c_arg.as(:c_arg)).repeat).maybe.as(:c_args) >> rparen } 

    rule(:step)               { space? >> keyword >> paren_group >> c_args }

    root(:step)
  end

  class CStepTransform < Parslet::Transform
    rule(
      keyword: simple(:keyword), 
      regex: simple(:regex), 
      c_args: subtree(:args)) { 
        arguments = args.nil? ? [] : [args].flatten

        CStep.new(
          keyword.to_s.downcase.camelize ,
          Regexp.new(regex.to_s),
          arguments.map do |arg| 
            arg = arg[:c_arg]
            CArg.new(arg[:c_type].to_s, arg[:c_identifier].to_s)
          end 
        )
      }
  end

end
