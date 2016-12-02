import { padTwo } from "utils";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import referralCityIds from "controller_helpers/referral_city_ids";
import { memoizePerRender } from "utils";

const factory = (args) => {
  let { hasSubkeys, defaultValue, key } = args;

  if (hasSubkeys){
    return memoizeSubkeyedFn(
      (model, subKey) => {
        return _.get(
          model,
          [ "ui", "tabs", selectedTabKey(model), "filterValues", key, subKey ],
          defaultValue
        );
      }
    )
  }
  else {
    return ((model) => {
      return _.get(
        model,
        [ "ui", "tabs", selectedTabKey(model), "filterValues", key ],
        defaultValue
      );
    }).pwPipe(memoizePerRender)
  }
};

const memoizeSubkeyedFn = (toMemoize) => {
  let cachedModel = null;
  let cache = {};

  return (model, subkey) => {
    if (model !== cachedModel) {
      cachedModel = model;
      cache = {}
    }

    if (_.isUndefined(cache[subkey])){
      cache[subkey] = toMemoize(model, subkey);
    }

    return cache[subkey];
  }
}

const currentMonth = () => {
  return `${(new Date).getUTCFullYear()}${padTwo((new Date).getMonth() + 1)}`;
}

export const startMonth = factory({
  key: "startMonth",
  hasSubkeys: false,
  defaultValue: currentMonth()
});

export const endMonth = factory({
  key: "endMonth",
  hasSubkeys: false,
  defaultValue: currentMonth()
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

export const bookingWaitTime = factory({
  key: "bookingWaitTime",
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

export const cities = memoizeSubkeyedFn(
  (model, subKey) => {
    return _.get(
      model,
      [ "ui", "tabs", selectedTabKey(model), "filterValues", "cities", subKey ],
      _.includes(referralCityIds(model), subKey)
    );
  }
);

export const isPublic = factory({
  key: "isPublic",
  hasSubkeys: false,
  defaultValue: false
})

export const isPrivate = factory({
  key: "isPrivate",
  hasSubkeys: false,
  defaultValue: false
})

export const isWheelchairAccessible = factory({
  key: "isWheelchairAccessible",
  hasSubkeys: false,
  defaultValue: false
})

export const subcategories = memoizeSubkeyedFn(
  (model, subkey) => {
    if (subkey) {
      return _.get(
        model,
        [ "ui", "tabs", selectedTabKey(model), "filterValues", "subcategories", subkey ],
        false
      );
    }
    else {
      return _.get(
        model,
        [ "ui", "tabs", selectedTabKey(model), "filterValues", "subcategories"],
        "0"
      );
    }
  }
)

export const specializations = factory({
  key: "specializations",
  hasSubkeys: false,
  defaultValue: "0"
})

export const showHiddenUpdates = factory({
  key: "showHiddenUpdates",
  hasSubkeys: false,
  defaultValue: false
})

export const entityType = factory({
  key: "entityType",
  hasSubkeys: false,
  defaultValue: "specialists"
});

export const month = factory({
  key: "month",
  hasSubkeys: false,
  defaultValue: currentMonth()
});

export const reportStyle = factory({
  key: "reportStyle",
  hasSubkeys: false,
  defaultValue: "summary"
});

export const completeThisWeekend = factory({
  key: "completeThisWeekend",
  hasSubkeys: false,
  defaultValue: false
});

export const completeNextMeeting = factory({
  key: "completeNextMeeting",
  hasSubkeys: false,
  defaultValue: false
});

export const notTargeted = factory({
  key: "notTargeted",
  hasSubkeys: false,
  defaultValue: false
});

export const assignees = factory({
  key: "assignees",
  hasSubkeys: false,
  defaultValue: "All"
});

export const issueSource = factory({
  key: "issueSource",
  hasSubkeys: false,
  defaultValue: "0"
});

export const priority = factory({
  key: "priority",
  hasSubkeys: false,
  defaultValue: "0"
});
