import _ from "lodash";
import { selectedTableHeadingKey } from "controller_helpers/table_headings";

const sortIteratees = (model) => {
  return unboundIteratees(model).map((iteratee) => _.partialRight(iteratee, model));
};

const unboundIteratees = (model) => {
  switch(selectedTableHeadingKey(model)) {
  case "NAME":
    return [ name ];
  case "SPECIALTIES":
    return [ specializationNames ];
  case "REFERRALS":
    if (model.app.currentUser.cityRankingCustomized) {
      return [
        referrals,
        cityPriority,
        waittimes
      ];
    }
    else {
      return [
        referrals,
        waittimes
      ];
    }
  case "WAITTIME":
    return [
      waittimes,
      cityPriority
    ];
  case "CITY":
    return [
      cityPriority,
      referrals,
      waittimes
    ];
  case "TITLE":
    return [ title ];
  case "SUBCATEGORY":
    return [ subcategory ];
  case "PAGE_VIEWS":
    return [ pageViews ];
  }
}

const referrals = (decoratedRecord, model) => {
  return (STATUS_CLASS_KEY_RANKINGS[decoratedRecord.raw.statusClassKey] || 99);
};

const waittimes = (decoratedRecord, model) => {
  return (WAITTIME_RANKINGS[decoratedRecord.raw.waittime] || 99);
};

const cityPriority = (decoratedRecord, model) => {
  return _.min(decoratedRecord.raw.cityIds.map((cityId) => {
    return model.app.currentUser.cityRankings[cityId];
  }));
};

const cityNames = (decoratedRecord, model) => {
  return decoratedRecord.cityNames;
};

const specializationNames = (decoratedRecord, model) => {
  return decoratedRecord.specializationNames;
};

const name = (decoratedRecord, model) => {
  if (decoratedRecord.raw.collectionName === "specialists") {
    return decoratedRecord.raw.lastName.toLowerCase();
  }
  else {
    return decoratedRecord.raw.name.toLowerCase().pwPipe(_.trimLeft);
  }
}

const title = (decoratedRecord, model) => {
  return decoratedRecord.raw.title.toLowerCase();
}

const subcategory = (decoratedRecord, model) => {
  return decoratedRecord.subcategoryName;
}

const pageViews = (decoratedRecord, model) => {
  return decoratedRecord.raw.pageViews;
}

const STATUS_CLASS_KEY_RANKINGS = {
  1: 1,
  2: 5,
  3: 3,
  4: 6,
  5: 4,
  6: 99,
  7: 2
};

const WAITTIME_RANKINGS = {
  ["Within one week"]: 1,
  ["1-2 weeks"]: 2,
  ["2-4 weeks"]: 3,
  ["1-2 months"]: 4,
  ["2-4 months"]: 5,
  ["4-6 months"]: 6,
  ["6-9 months"]: 7,
  ["9-12 months"]: 8,
  ["12-18 months"]: 9,
  ["18-24 months"]: 10,
  ["2-2.5 years"]: 11,
  ["2.5-3 years"]: 12,
  [">3 years"]: 13
}

export default sortIteratees;
