import * as Type from "@dashkite/joy/type"

# sigh...
isType = ( term ) -> 
  term?.prototype?.constructor?.name?[0] <= "a"

transform = ( term ) ->
  if Type.isFunction term
    if isType term
      Type.isKind term
    else
      term
  else
    ( value ) -> term == value

export default transform