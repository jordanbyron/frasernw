// expose bootstrapping functions on the window
// so we can call them on specific pages

window.pathways = window.pathways || {}
window.pathways.bootstrapTest =
  require("./bootstrap/test")
