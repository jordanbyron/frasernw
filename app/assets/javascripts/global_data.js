(function(pathways){

  var expiryKey = function(cacheVersion) {
    var date = new Date()

    return (date.getDate().toString() + date.getMonth().toString() + date.getYear().toString() + cacheVersion.toString());
  };

  var fetchGlobalData = function(deferred, cacheVersion) {
    $.get("/data_tables/global_data").done(function(data) {
      deferred.resolve(data);

      window.localStorage.pathwaysGlobalData = JSON.stringify(data);
      window.localStorage.pathwaysGlobalDataExpiration = expiryKey(cacheVersion);
    })
  };

  var isGlobalDataSet = function(cacheVersion) {
    return (window.localStorage.pathwaysGlobalDataExpiration === expiryKey(cacheVersion) &&
      window.localStorage.pathwaysGlobalData != undefined);
  };

  pathways.localstorage_cache_version = function(cacheVersion){
    pathways.globalDataLoaded = function(){
      var deferred = $.Deferred();

      if (isGlobalDataSet(cacheVersion)) {
        deferred.resolve(
          JSON.parse(window.localStorage.pathwaysGlobalData)
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
