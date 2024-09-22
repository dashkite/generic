# adapted from:
# https://stackoverflow.com/a/36871498

class ExtensibleFunction extends Function
  constructor: ( f ) ->
     # need explicit return here because CS doesn't
     # generate one for constructors
    return Object.setPrototypeOf f, new.target.prototype

export default ExtensibleFunction