// These libraries are required to support React.js in older browsers
// (see http://facebook.github.io/react/docs/working-with-the-browser.html)
//

require("es5-shim/es5-shim.js");
require("es5-shim/es5-sham.js");
require("console-polyfill");

// Scripts we expose on the global namespace so we can call them from ruby
// partials and non-webpacked js

window.pathways = window.pathways || {};

window.pathways.bootstrapReact = require("./bootstrap_react");

window.pathways.trackForm = require("./analytics_wrappers").trackForm;
window.pathways.trackContentItem = require("./analytics_wrappers").trackContentItem;
