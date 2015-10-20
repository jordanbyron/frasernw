// we use these functions to standardize tracking navigation to external links

var trackExternalPageView = function(_gaq, itemId, collection) {
  _gaq.push(['_trackEvent', collection, 'clicked', itemId ])

  return true;
}

module.exports = {
  trackForm: function(_gaq, itemId) {
    return trackExternalPageView(_gaq, itemId, "forms");
  },
  trackContentItem: function(_gaq, itemId) {
    return trackExternalPageView(_gaq, itemId, "content_items");
  }
}
