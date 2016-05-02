Object.defineProperty(Object.prototype, 'pipe', {
  value: function (transform) { return transform(this); }
});

Object.defineProperty(Function.prototype, 'pipe', {
  value: function (transform) {
    var caller = this;

    return function(arg){
      return transform(caller(arg));
    };
  }
});
