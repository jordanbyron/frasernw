(function (pathways) {
  var _cellGenerators = {
    attr: function(attrName) {
      return function(record) {
        return record[attrName]
      }
    }
  }

  var _createRowGenerator = function(cellGenerators) {
    return function(record) {
      return cellGenerators.map(function( cellGenerator ) {
        return cellGenerator(record);
      });
    };
  }

  window.pathways.rowGenerators = {
    exampleTable: _createRowGenerator([
      _cellGenerators.attr("id"),
      _cellGenerators.attr("name"),
      _cellGenerators.attr("date"),
      function(record) { return "www.google.ca" }
    ])
  }
}(window.pathways = window.pathways || {}));
