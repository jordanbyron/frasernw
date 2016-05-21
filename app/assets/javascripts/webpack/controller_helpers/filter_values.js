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

export const startMonth = factory({
  key: "startMonth",
  hasSubkey: false,
  defaultValue: `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
});

export const endMonth = factory({
  key: "endMonth",
  hasSubkey: false,
  defaultValue: `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
});

export const divisionScope = factory({
  key: "divisionScope",
  hasSubkey: false,
  defaultValue: 0
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

export const sex = factory({
  key: "sex",
  hasSubkey: true,
  defaultValue: false
});

export const scheduleDays = factory({
  key: "scheduleDays",
  hasSubkey: true,
  defaultValue: false
});

export const careProviders = factory({
  key: "careProviders",
  hasSubkey: true,
  defaultValue: false
});

export const procedures = factory({
  key: "procedures",
  hasSubkey: true,
  defaultValue: false
})
