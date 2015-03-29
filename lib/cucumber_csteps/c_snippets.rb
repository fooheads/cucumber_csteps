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
