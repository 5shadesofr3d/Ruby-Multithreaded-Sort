require_relative 'RLisp'

l = RLisp.new
l.eval [:label, :x, 15]
l.eval :x
#=> 15
l.eval [:eq, 17, :x]
#=> false
l.eval [:eq, 15, :x]
#=> true
l.eval [:quote, [7, 10, 12]]
#=> [7, 10, 12]
l.eval [:car, [:quote, [7, 10, 12]]]
#=> 7
l.eval [:cdr, [:quote, [7, 10, 12]]]
#=> [10,12]
l.eval [:cons, 5, [:quote, [7, 10, 12]]]
#=> [5, 7, 10, 12]
l.eval [:if, [:eq, 5, 7], 6, 7]
#=> 7
l.eval [:atom, [:quote, [7, 10, 12]]]
#=> false
l.eval [:label, :second, [:quote, [:lambda, [:x], [:car, [:cdr, :x]]]]]
l.eval [:second, [:quote, [7, 10, 12]]]
#=> 10