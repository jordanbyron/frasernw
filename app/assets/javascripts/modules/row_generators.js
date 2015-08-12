(function (pathways) {
  var cellGenerators = {
    attr: function(attrName) {
      return function(record) {
        return record[attrName]
      }
    }
  }

  window.pathways.rowGenerators = {
    exampleTable: [
      cellGenerators.attr("id"),
      cellGenerators.attr("name"),
      cellGenerators.attr("date"),
      function(record) { return "www.google.ca" }
    ]
  }

  window.pathways.applyRowGenerator = function(rowGenerator, records) {
    var _generateRow =  function( record ) {
      return rowGenerator.map(function( fn ) {
        return fn(record);
      })
    };

    return records.map(_generateRow);
  }
}(window.pathways = window.pathways || {}));
