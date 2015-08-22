require("./react_ujs.custom")
  .mountComponentsOnLoad();

window.pathways = window.pathways || {};
window.pathways.bootstrap = {
  showSpecialization: require("./bootstrap/show_specialization")
}
