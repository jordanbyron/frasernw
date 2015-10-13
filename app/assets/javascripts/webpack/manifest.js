// These libraries are required to support React.js in older browsers
// (see http://facebook.github.io/react/docs/working-with-the-browser.html)
//

require("es5-shim/es5-shim.js");
require("es5-shim/es5-sham.js");
require("console-polyfill");

window.pathways = window.pathways || {};
window.pathways.bootstrap = {
  showSpecialization: require("./bootstrap/specialization_page")
}
