import _ from "lodash";

export const noSelect = {
  WebkitTouchCallout: "none",
  WebkitUserSelect: "none",
  KhtmlUserSelect: "none",
  MozUserSelect: "none",
  msUserSelect: "none",
  userSelect: "none"
};

export const buttonIsh = _.merge({cursor: "pointer"}, noSelect);

export const halfColumnCheckbox = {
  display: "inline-block",
  width: "90px"
};
