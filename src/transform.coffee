import { isType as isTypeOf, isFunction, isObject } from "@dashkite/joy/type"

# hopefully we can do better than this somehow...
isType = ( value ) -> 
  value?.prototype?.constructor?.name?[0] <= "a"

equal = ( value ) ->
  ( target ) -> value == target

transform = ( term ) ->
  if isFunction term
    if isType term
      isTypeOf term
    else
      term
  else
    equal term

export default transform