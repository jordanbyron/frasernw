window.pathways = window.pathways || {};

var updateDOM = function($checkbox, $contentContainer) {
  if ($checkbox.is(":checked")) {
    $contentContainer.show();
  } else {
    $contentContainer.hide();
  }
};

window.pathways.checkboxSlidedown = function(config) {
  $checkbox = $("#" + config.checkboxId);
  $contentContainer = $("#" + config.contentContainerId);

  $checkbox.change(function() {
    updateDOM($checkbox, $contentContainer);
  });
  $(document).ready(function() {
    updateDOM($checkbox, $contentContainer);
  });
};
