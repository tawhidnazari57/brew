# typed: strict
# frozen_string_literal: true

module RuboCop
  module Cop
    module Homebrew
      # This injects exclusion patterns into the `Style/MutableConstant` cop to skip
      #   constants that we are unable to freeze.
      # FIXME: Remove when https://github.com/sorbet/sorbet/issues/3532 is fixed.
      module SkipSorbetConstantAssignments
        extend NodePattern::Macros

        def_node_matcher :t_type_alias?, "(block (send (const {nil? cbase} :T) :type_alias ...) ...)"
        def_node_matcher :t_type_member?, "(block (send nil? :type_member ...) ...)"

        sig { params(node: AST::CasgnNode).void }
        def on_casgn(node)
          _scope, _const_name, value = *node
          return if t_type_alias?(value)
          return if t_type_member?(value)

          super
        end
      end
    end
  end
end

module RuboCop
  module Cop
    module Style
      class MutableConstant < Base
        prepend Homebrew::SkipSorbetConstantAssignments
      end
    end
  end
end
