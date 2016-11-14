import _ from "lodash";

const setupTabHistory = (defaultTab) => {
  $(document).ready(() => {
    $('a[data-toggle="tab"]').on("click", function(e){
      const linkClicked = this;

      window.location.hash = linkClicked.getAttribute("href");

      return false;
    });

    updateUiFromHash(defaultTab);

    window.addEventListener("hashchange", _.partial(updateUiFromHash, defaultTab));
  })
};


const updateUiFromHash = (defaultTab) => {
  if(window.location.hash.length > 0){
    $(`a[data-toggle='tab'][href='${window.location.hash}']`).tab("show");
    updatePagination(window.location.hash);
  }
  else if (defaultTab){
    $(`a[data-toggle='tab'][href='${defaultTab}']`).tab("show")
    updatePagination(defaultTab);
  }
  else {
    $(`a[data-toggle='tab']`).first().tab("show");
  }
}

const updatePagination = (newHash) => {
  $(".pagination a").each((index, elem) => {
    if (elem.href.indexOf("#") !== -1){
      var root = elem.href.slice(0, elem.href.indexOf("#"));
    }
    else {
      var root = elem.href;
    }

    elem.href = `${root}${newHash}`
  })
}

export default setupTabHistory;
