(function(pathways){

  var dateNum = function() {
    var date = new Date()

    return (date.getDate().toString() + date.getMonth().toString() + date.getYear().toString());
  };

  var fetchGlobalData = function(deferred) {
    $.get("/data_tables/global_data").done(function(data) {
      deferred.resolve(data);

      window.localStorage.pathwaysGlobalData = JSON.stringify(data);
      window.localStorage.pathwaysGlobalDataExpiration = dateNum();
    })
  };

  var isGlobalDataSet = function() {
    return (window.localStorage.pathwaysGlobalDataExpiration === dateNum() &&
      window.localStorage.pathwaysGlobalData != undefined);
  };

  pathways.setGlobalDataPromise = function(){
    pathways.globalDataLoaded = function(){
      var deferred = $.Deferred();

      if (isGlobalDataSet()) {
        deferred.resolve(
          JSON.parse(window.localStorage.pathwaysGlobalData)
        );
      } else {
        $(document).ready(function() {
          fetchGlobalData(deferred);
        });
      }

      return deferred.promise();
    }();
  };
}(window.pathways = window.pathways || {}));
