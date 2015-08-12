(function( pathways ) {
  pathways.createTableDataStore = function( config ) {
    var _records = config["records"] || [];
    var _headings = config["headings"] || [];
    var _updateNotifiers = [];
    var _rowGenerator = config["rowGenerator"];

    var _notifyUpdated = function() {
      _updateNotifiers.forEach(function( callback ) {
        callback.call();
      });
    };

    var _bodyRows = function() {
      return pathways.applyRowGenerator(_rowGenerator, _records);
    }

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
            bodyRows: _bodyRows(),
            headings: _headings
          };
        },
        setUpdateListener: function( callback ) {
          _updateNotifiers.push(callback);
        }
      }
    };
  };
}(window.pathways));
