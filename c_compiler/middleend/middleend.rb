require_relative "constprop.rb"
require_relative "deadcode.rb"
require_relative "ssa.rb"
def optimize(ast)
  ast=tossa(ast)
  ast=constprop(ast)
  # ast=deadcode(ast)
  # ast=fromssa(ast)
  return ast
end
