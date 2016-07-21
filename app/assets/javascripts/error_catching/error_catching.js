var wrapErrors = function(fn) {
  if (!fn.__wrapped__) {
    fn.__wrapped__ = function () {
      try {
        return fn.apply(this, arguments);
      } catch (e) {
        captureError(e);
        throw e;
      }
    };
  }
  return fn.__wrapped__;
}
var startErrorLog = function() {
  window.onerror = (message,file,line,column,errorObject) => {
    console.log(message, "from", errorObject.stack);
    column = column || (window.event && window.event.errorCharacter);
    let stack = errorObject ? errorObject.stack : null;
    if(!stack) {
      let stack = [];
      let trace = arguments.callee.caller;
      while (trace) {
        stack.push(trace.name);
        trace = trace.caller;
      }
      errorObject['stack'] = stack;
    }
    let errorData = {
      message: message,
      file: file,
      line: line,
      column: column,
      url: document.location.href,
      errorStack: stack
    };
    notifyError(errorData);
    return false;
  }
  // window.addEventListener("error", function(e) {
  //   console.log(e.error.message, "from", e.error.stack);
  //   var errorObject = e ? e.error : null;
  //   if(!errorObject) {
  //     var stack = [];
  //     var trace = arguments.callee.caller;
  //     while (trace) {
  //       stack.push(trace.name);
  //       trace = trace.caller;
  //     }
  //     errorObject['stack'] = stack;
  //     errorObject['message'] = "Script error";
  //   } else {
  //     errorObject['stack'] = e.error.stack
  //     errorObject['message'] = e.error.message
  //   };
  //   captureError(e);
  // },
  // false
  // );
}
var captureError = function(e) {
  let errorData = {
    name: e.name,
    message: e.message,
    url: document.location.href,
    errorStack: e.stack
  };
  notifyError(errorData);
}
var notifyError = function(errorData) {
  let xhttp = new XMLHttpRequest();
  xhttp.open("POST", '/notifications', true);
  xhttp.setRequestHeader("Content-type", "application/json;charset=UTF-8");
  xhttp.send(JSON.stringify(errorData));
}
