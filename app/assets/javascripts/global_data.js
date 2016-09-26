// globals: vendor.lzString, $

(function(pathways){
  var expiryKey = function(cacheVersion) {
    var date = new Date()

    return (date.getDate().toString() + date.getMonth().toString() + date.getYear().toString() + cacheVersion.toString());
  };

  var fetchGlobalData = function(deferred, cacheVersion) {
    $.get("/data_tables/global_data").done(function(data) {
      deferred.resolve(data);

      setTimeout(function(){
        window.localStorage.pathwaysGlobalData = vendor.lzString.compressToUTF16(JSON.stringify(data));
        window.localStorage.pathwaysGlobalDataExpiration = expiryKey(cacheVersion);
      }, 200);
    }).fail(function(response, textStatus, error) {
      throw error;
    })
  };

  var isGlobalDataSet = function(cacheVersion) {
    return (window.localStorage.pathwaysGlobalDataExpiration === expiryKey(cacheVersion) &&
      window.localStorage.pathwaysGlobalData != undefined);
  };

  pathways.loadGlobalData = function(cacheVersion){
    pathways.globalDataLoaded = function(){
      var deferred = $.Deferred();

      if (isGlobalDataSet(cacheVersion)) {
        deferred.resolve(
          JSON.parse(vendor.lzString.decompressFromUTF16(window.localStorage.pathwaysGlobalData))
        );
      } else {
        $(document).ready(function() {
          fetchGlobalData(deferred, cacheVersion);
        });
      }

      return deferred.promise();
    }();
  };
}(window.pathways = window.pathways || {}));
