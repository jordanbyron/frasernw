(function (pathways) {
  var attr = function(attrName) {
    return function(record) {
      return record[attrName]
    }
  }

  window.pathways.rowGenerators = {
    exampleTable: [
      attr("id"),
      attr("name"),
      attr("date"),
      function(record) { return "www.google.ca" }
    ]
  }
}(window.pathways = window.pathways || {}));
