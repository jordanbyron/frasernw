(function( pathways ) {
  pathways.createTableDataStore = function( config ) {
    var _records = config["records"] || [];
    var _headings = config["headings"] || [];
    var _updateNotifiers = [];
    var _rowGenerator = config["rowGenerator"];

    var _generateRows =  function( records ) {
      return _records.map(_generateRow);
    };

    var _generateRow =  function( record ) {
      return _rowGenerator.map(function( fn ) {
        return fn(record);
      })
    };

    var _notifyUpdated = function() {
      _updateNotifiers.forEach(function( callback ) {
        callback.call();
      });
    };

    pathways.tableDataStores = pathways.tableDataStores || {};
    return pathways.tableDataStores[config.address] = {
      setRecords: function( records ) {
        _records = records;
        _notifyUpdated();
      },
      setHeadings: function( headings ) {
        _headings = headings;
        _notifyUpdated();
      },
      clientFunctions: {
        getData: function() {
          return {
            bodyRows: _generateRows(_records),
            headings: _headings
          };
        },
        setUpdateListener: function( callback ) {
          _updateNotifiers.push(callback);
        }
      }
    };
  };
}(window.pathways = window.pathways || {}));
