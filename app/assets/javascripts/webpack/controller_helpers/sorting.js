import _ from "lodash";

export const selectedTableHeadingKey = (model) => {
  return _.get(model, ["ui", "selectedTableHeading", "key"], "PAGE_VIEWS")
}

export const tableSortDirection = (model) => {
  return _.get(model, ["ui", "selectedTableHeading", "direction"], "DOWN");
}
