import { padTwo } from "utils";
import { selectedTabKey } from "controller_helpers/tab_keys";

const factory = (args) => {
  let { hasSubkey, defaultValue, key } = args;

  if (hasSubkey){
    return (model, subKey) => {
      return _.get(
        model,
        [ "ui", "tabs", selectedTabKey(model), "filterValues", key, subKey ],
        defaultValue
      );
    };
  }
  else {
    return (model) => {
      return _.get(
        model,
        [ "ui", "tabs", selectedTabKey(model), "filterValues", key ],
        defaultValue
      );
    };
  }
};

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

export const procedure = factory({
  key: "procedures",
  hasSubkey: true,
  defaultValue: false
});

export const acceptsReferralsViaPhone = factory({
  key: "acceptsReferralsViaPhone",
  hasSubkey: false,
  defaultValue: false
});

export const patientsCanCall = factory({
  key: "patientsCanCall",
  hasSubkey: false,
  defaultValue: false
});

export const respondsWithin = factory({
  key: "respondsWithin",
  hasSubkey: false,
  defaultValue: 0
});
