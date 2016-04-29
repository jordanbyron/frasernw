import { padTwo } from "utils";

export function startMonth(model) {
  return _.get(
    model,
    ["ui", "filterValues", "startMonth"],
    `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
  );
}
