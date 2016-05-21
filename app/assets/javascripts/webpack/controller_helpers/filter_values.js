import { padTwo } from "utils";
import { selectedTabKey } from "controller_helpers/tab_keys";

const factory = (args) => {
  let { hasSubkeys, defaultValue, key } = args;

  if (hasSubkeys){
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
  hasSubkeys: false,
  defaultValue: `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
});

export const endMonth = factory({
  key: "endMonth",
  hasSubkeys: false,
  defaultValue: `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`
});

export const divisionScope = factory({
  key: "divisionScope",
  hasSubkeys: false,
  defaultValue: 0
});

export const acceptsReferralsViaPhone = factory({
  key: "acceptsReferralsViaPhone",
  hasSubkeys: false,
  defaultValue: false
});

export const patientsCanCall = factory({
  key: "patientsCanCall",
  hasSubkeys: false,
  defaultValue: false
});

export const respondsWithin = factory({
  key: "respondsWithin",
  hasSubkeys: false,
  defaultValue: 0
});

export const sex = factory({
  key: "sex",
  hasSubkeys: true,
  defaultValue: false
});

export const scheduleDays = factory({
  key: "scheduleDays",
  hasSubkeys: true,
  defaultValue: false
});

export const careProviders = factory({
  key: "careProviders",
  hasSubkeys: true,
  defaultValue: false
});

export const procedures = factory({
  key: "procedures",
  hasSubkeys: true,
  defaultValue: false
})

export const teleserviceFeeTypes = factory({
  key: "teleserviceFeeTypes",
  hasSubkeys: true,
  defaultValue: false
})

export const teleserviceRecipients = factory({
  key: "teleserviceRecipients",
  hasSubkeys: true,
  defaultValue: false
})

export const interpreterAvailable = factory({
  key: "interpreterAvailable",
  hasSubkeys: false,
  defaultValue: false
})

export const languages = factory({
  key: "languages",
  hasSubkeys: true,
  defaultValue: false
})

export const clinicAssociations = factory({
  key: "clinicAssociations",
  hasSubkeys: false,
  defaultValue: 0
})

export const hospitalAssociations = factory({
  key: "hospitalAssociations",
  hasSubkeys: false,
  defaultValue: 0
})
