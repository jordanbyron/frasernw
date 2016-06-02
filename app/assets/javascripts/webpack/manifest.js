
// These libraries are required to support React.js in older browsers
// (see http://facebook.github.io/react/docs/working-with-the-browser.html)
//

import "es5-shim/es5-shim.js";
import "es5-shim/es5-sham.js";
import "console-polyfill";
import "core_extensions";

import attachSecretEditLinks from "window_scripts/secret_edit_links";
import setupTabHistory from "window_scripts/setup_tab_history";
import bootstrapReact from "bootstrap_react";

import Highcharts from "highcharts";
import "jquery-ujs";

// Scripts we expose on the global namespace so we can call them from ruby
// partials and non-webpacked js

window.pathways = window.pathways || {};

window.pathways.bootstrapReact = bootstrapReact;

window.pathways.trackForm = require("./analytics_wrappers").trackForm;
window.pathways.trackContentItem = require("./analytics_wrappers").trackContentItem;
window.pathways.attachSecretEditLinks = attachSecretEditLinks;
window.pathways.setupTabHistory = setupTabHistory;

window.vendor = {}
window.vendor._ = require("lodash");
window.vendor.lzString = require("lz-string");

window.vendor.Highcharts = Highcharts;
