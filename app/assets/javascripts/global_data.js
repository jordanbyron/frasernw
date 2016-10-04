// globals: vendor.lzString, $

(function(pathways){
  pathways.loadGlobalData = function(cacheVersion){
    return $.ajax({
      url: ("/global_data/" + cacheVersion.toString()),
      headers: { "Cache-Control" : "public, max-age=86400" }
    }).fail(function(response, textStatus, error) {

      throw error;
    });
  };
}(window.pathways = window.pathways || {}));
