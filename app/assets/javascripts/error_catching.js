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
    var token = (
      document.getElementsByName("csrf-token")[0].getAttribute("content")
    );
    var errorData = {
      message: message,
      file: file,
      line: line,
      column: column,
      url: document.location.href,
      errorStack: stack.toString()
    };
    notifyError(errorData, token);
    return false;
  }
}
var notifyError = function(errorData, token) {
  var xhttp = new XMLHttpRequest();
  xhttp.open("POST", '/notifications', true);
  xhttp.setRequestHeader("Content-type", "application/json;charset=UTF-8");
  xhttp.setRequestHeader("X-CSRF-Token", token);
  xhttp.send(JSON.stringify(errorData));
}
