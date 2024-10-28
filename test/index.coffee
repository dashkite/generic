import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { isFunction, eq, gte, memoize } from "@dashkite/joy"

import Generic from "../src"

do ->

  print await test "Generics", [

    test "Fibonacci function", do ->

      fib = Generic.make "fib", "Fibonacci sequence"
        .define [ gte 0 ], memoize ( n ) -> ( fib n - 1 ) + ( fib n - 2 )
        .define [ eq 1 ], -> 1
        .define [ eq 2 ], -> 1

      [

        test "matches simple predicates", ->
          assert ( fib 5 ) == 5

        test "throws with name/arguments on type error", ->
          assert.throws (-> fib 0),
            message: "fib: invalid arguments."
            arguments: [ 0 ]

      ]

    test "Polymorphic dispatch", ->

      class XString extends String

      greet = Generic.make "greet"
        .define [ String ], ( greeting ) -> greeting
        .define [ XString ], ( greeting ) -> "#{ greeting }!"

      assert.equal "hello", greet "hello"
      assert.equal "hello!", greet new XString "hello"
      assert.throws -> greet undefined

    test "Variadic arguments", ->

      list = Generic.make "list"
      list.define [ -> true ], ( args... ) -> args

      assert.deepEqual [ 1, 2, 3 ], list 1, 2, 3


    test "built-in types", ->

      list = Generic.make "list"
        .define [ Object ], ( object ) -> Object.entries object
        .define [ Array ], ( array ) -> array
      
      assert.deepEqual [1..5 ], list [ 1..5 ]
      assert.deepEqual [ [ "foo", "bar" ]], list foo: "bar"

    test "Generics are functions", ->
      assert isFunction Generic.make "test"

    test "Lookups", ->

      double = Generic.make "double"
        .define [ Number ], ( x ) -> x * 2
        .define [ String ], ( text ) -> text.repeat 2

      f = double.lookup [ 5 ]
      g = double.lookup "*"
      assert.equal 10, f 5
      assert.equal "**", g "*"

    test "Method Dispatch", ->

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
  
  ]

  process.exit if success then 0 else 1

