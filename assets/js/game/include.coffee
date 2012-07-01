define
  include: (klass, mixin) ->
    klass.prototype[name] = method for name, method of mixin
    return klass.prototype