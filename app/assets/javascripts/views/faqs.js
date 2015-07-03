(function($){
  $(document).ready(function() {
    $(".faqs").sortable({
      axis: "y",
      handle: ".faqs__admin_icon--handle",
      update: function() {
        $.post($(this).data("update-url"), $(this).sortable('serialize'))
      }
    })
  })
}(window.$))
