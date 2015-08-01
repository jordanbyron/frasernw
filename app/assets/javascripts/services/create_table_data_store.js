(function( pathways ) {
  pathways.createAddressedTableDataStore = function( config ) {
    var _records = [];
    var _headings = [];
    var _updateNotifiers = [];

    var _generateRows =  function( records ) {
      return _records.map(_generateRow);
    };

    var _generateRow =  function( record ) {
      return _rowGenerator().map(function( fn ) {
        return fn(record);
      })
    };

    var _rowGenerator = function() {
      return window.pathways.rowGenerators[config.rowGeneratorAddress];
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
