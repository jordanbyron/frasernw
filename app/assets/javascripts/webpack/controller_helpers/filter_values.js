import { padTwo } from "utils";

export function startMonth(model) {
  return _.get(
    model,
    ["ui", "filterValues", "startMonth"],
    `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
  );
}

export function endMonth(model) {
  return _.get(
    model,
    ["ui", "filterValues", "endMonth"],
    `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
  );
}

export function divisionScope(model) {
  return _.get(
    model,
    ["ui", "filterValues", "divisionScope"],
    0
  );
}
