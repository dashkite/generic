import transform from "./transform"
import ExtensibleFunction from "./extensible-function"

class GenericFunction extends ExtensibleFunction

  @make: do ({ make } = {}) ->

    make = new GenericFunction
      name: "Generic.make"
      description: "Create a generic function"

    make.define [ Object ], ( specifier ) ->
      new GenericFunction specifier

    make.define [ String ], ( name ) ->
      new GenericFunction { name }

    make.define [ String, String ], ( name, description ) ->
      new GenericFunction { name, description }

    make.define [ String, Function ], ( name, f) ->
      new GenericFunction { name, default: f }
    
    make.define [ String, String, Function ], ( name, description, f ) ->
      new GenericFunction { name, description, default: f }

    make.define [ String, Function, String ], ( name, f, description ) ->
      new GenericFunction { name, description, default: f }
  
    make

  @define: ( target, terms, f ) -> target.define terms, f

  @lookup: ( target, args ) -> target.lookup args

  @dispatch: ( target, args ) -> target.dispatch args

  constructor: ({ name, @description, @default }) ->
    # we need to forward declare self because we
    # can't assign to `this` until we call super
    self = undefined
    super ( args... ) -> self.dispatch args, @
    self = @
    # override the built-in name property
    Object.defineProperty this, "name", 
      value: name ? "anonymous-generic"
      writable: false

    @entries = []
    @default ?= (args...) =>
      error = new TypeError "#{ @name }: invalid arguments"
      error.arguments = args
      throw error

  description: ( @description ) -> @

  set: ( key, value ) -> 
    @[ key ] = value
    @
  
  define: ( terms, f ) ->
    terms = terms.map transform
    @entries.unshift { terms, f }
    @

  lookup: ( args ) ->

    # go through each definition in our lookup 'table'
    for { terms, f } in @entries

      # there must be at least one argument per term
      # (variadic terms can consume multiple arguments,
      # so the converse is not true)
      continue if terms.length > args.length

      # allow for the nullary function
      return f if terms.length == 0 && args.length == 0

      # we can't have a match if we don't match any terms
      match = false

      # each argument must be consumed
      i = 0
      while i < args.length

        # if there's no corresponding term, we have leftover
        # arguments with no term to consume them, so move on
        if !( term = terms[i] )?
          match = false
          break

        # if the term may be variadic (indicated by taking 0 arguments)
        # and this is the last available term
        # try the term with the remaining arguments
        if ( terms.length == i + 1 ) && term.length == 0
          match = term args[ i.. ]...
          break

        # otherwise, we have the default case, where we try to match
        # the next argument with the next term
        break if !( match = term args[i++] )

      # if we ended up with a match, just return the corresponding fn
      return f if match

    # if exit the loop without returning a match, return the default
    @default

  dispatch: ( args, self ) ->
    f = @lookup args
    f.apply self, args

export default GenericFunction
