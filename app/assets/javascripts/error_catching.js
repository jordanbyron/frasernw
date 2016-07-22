var startErrorLog = function() {
  window.onerror = function(message,file,line,column,errorObject) {
    var column = column || (window.event && window.event.errorCharacter);
    var stack = errorObject ? errorObject.stack : null;
    if(!stack) {
      var stack = [];
      var trace = arguments.callee.caller;
      while (trace) {
        stack.push(trace);
        trace = trace.caller;
      }
    }
    var errorData = {
      message: message,
      file: file,
      line: line,
      column: column,
      url: document.location.href,
      errorStack: stack.toString()
    };
    notifyError(errorData);
    return false;
  }
}
var notifyError = function(errorData) {
  var xhttp = new XMLHttpRequest();
  xhttp.open("POST", '/notifications', true);
  xhttp.setRequestHeader("Content-type", "application/json;charset=UTF-8");
  xhttp.send(JSON.stringify(errorData));
}
