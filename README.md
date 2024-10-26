# DashKite Generic

*Generic functions*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

## Examples

### Fibonacci Function

```coffeescript
import { memoize } from "@dashkite/joy/function"

fib = Generic.make "fib", "Fibonacci sequence"
  .define [ gte 0 ], memoize ( n ) -> ( fib n - 1 ) + ( fib n - 2 )
  .define [ eq 1 ], -> 1
  .define [ eq 2 ], -> 1

assert.equal 5, fib 5
assert.throws -> fib 0
```

### Polymorphism

```coffeescript
import { has } from "@dashkite/joy/object"

length = Generic.make "size", "Return the size of a value"
  # based on interface
  .define [ has "length" ], ( value ) -> value.length
  # based on type
  .define [ Object ], ( object ) -> ( Object.keys object ).length
  .define [ Set ], ( set ) -> set.values().length
  
assert.equal 5, size "hello"
assert.equal 3, size [ 1..3 ]
assert.equal 2, size x: 0, y: 0
assert.equal 1, size new Set [ true ]
```

### Method Dispatch

```coffeescript
class Adder
  constructor: ( @total = 0 ) ->
  add: ( f = Generic.make "Adder::add" )
    .define [ Number ], ( operand ) -> 
      @total += operand
      @
  
assert.equal 12, 
  ( new Adder )
    .add 5
    .add 7
    .total
```

