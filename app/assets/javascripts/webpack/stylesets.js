var merge = require("lodash/object/merge");

var noSelect = {
  WebkitTouchCallout: "none",
  WebkitUserSelect: "none",
  KhtmlUserSelect: "none",
  MozUserSelect: "none",
  msUserSelect: "none",
  userSelect: "none"
}

module.exports = {
  noSelect: noSelect,
  buttonIsh: merge({cursor: "pointer"}, noSelect),
  halfColumnCheckbox: {
    display: "inline-block",
    width: "90px"
  }
}
