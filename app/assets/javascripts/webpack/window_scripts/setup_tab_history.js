import _ from "lodash";

const setupTabHistory = (defaultTab) => {
  $(document).ready(() => {
    $('a[data-toggle="tab"]').on("click", function(e){
      var newHash = e.target.getAttribute("href");

      window.location.hash = newHash;

      $(".pagination a").each((index, elem) => {
        if (elem.href.indexOf("#") !== -1){
          var root = elem.href.slice(0, elem.href.indexOf("#"));
        }
        else {
          var root = elem.href;
        }

        elem.href = `${root}${newHash}`
      })

      return false;
    });

    setTabFromHash(defaultTab);

    window.addEventListener("hashchange", _.partial(setTabFromHash, defaultTab));
  })
};

const setTabFromHash = (defaultTab) => {
  if(window.location.hash.length > 0){
    $(`a[data-toggle='tab'][href='${window.location.hash}']`).tab("show");
  }
  else if (defaultTab){
    $(`a[data-toggle='tab'][href='${defaultTab}']`).tab("show")
  }
  else {
    $(`a[data-toggle='tab']`).first().tab("show");
  }
}

export default setupTabHistory;
