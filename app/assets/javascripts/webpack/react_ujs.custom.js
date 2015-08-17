// Globals: window, document
var React = require("react");
var ReactComponents = require("./react_components.manifest");
var $ = (typeof window.jQuery !== 'undefined') && window.jQuery;

var mountComponents = function(searchSelector) {
  var CLASS_NAME_ATTR = 'data-react-class';
  var PROPS_ATTR = 'data-react-props';
  // helper method for the mount and unmount methods to find the
  // `data-react-class` DOM elements
  var _findDOMNodes = function(searchSelector) {
    // we will use fully qualified paths as we do not bind the callbacks
    var selector;
    if (typeof searchSelector === 'undefined') {
      var selector = '[' + CLASS_NAME_ATTR + ']';
    } else {
      var selector = searchSelector + ' [' + CLASS_NAME_ATTR + ']';
    }

    if ($) {
      return $(selector);
    } else {
      return document.querySelectorAll(selector);
    }
  };

  var _mountComponents = function(searchSelector) {
    var nodes = _findDOMNodes(searchSelector);

    for (var i = 0; i < nodes.length; ++i) {
      var node = nodes[i];
      var className = node.getAttribute(CLASS_NAME_ATTR);

      // Assume className is simple and can be found at top-level (window).
      // Fallback to eval to handle cases like 'My.React.ComponentName'.
      var constructor = ReactComponents[className];
      var propsJson = node.getAttribute(PROPS_ATTR);
      var props = propsJson && JSON.parse(propsJson);

      React.render(React.createElement(constructor, props), node);
    }
  };

  _mountComponents(searchSelector)
};

var mountComponentsOnLoad = function() {
  if ($) {
    $(function() { mountComponents() });
  } else {
    document.addEventListener('DOMContentLoaded', function() {
      mountComponents()
    });
  }
}

module.exports = {
  mountComponents: mountComponents,
  mountComponentsOnLoad: mountComponentsOnLoad
}
