Object.defineProperty(Object.prototype, 'pwPipe', {
  value: function (transform) { return transform(this); }
});

Object.defineProperty(Function.prototype, 'pwPipe', {
  value: function (transform) {
    var caller = this;

    return function(arg){
      return transform(caller(arg));
    };
  }
});
