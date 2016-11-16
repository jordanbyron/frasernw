import _ from "lodash";
import { selectedTableHeadingKey, canSelectSort }
  from "controller_helpers/table_headings";
import { route } from "controller_helpers/routing";

const sortIteratees = (model) => {
  return unboundIteratees(model).map((iteratee) => _.partialRight(iteratee, model));
}

const unboundIteratees = (model) => {
  if(canSelectSort(model)){
    switch(selectedTableHeadingKey(model)) {
    case "NAME":
      return [ name ];
    case "SPECIALTIES":
      return [ specializationNames ];
    case "REFERRALS":
      if (model.app.currentUser.cityRankingsCustomized) {
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
    case "SPECIALTY":
      return [ name ];
    case "ENTITY_TYPE":
      return [ _.property("count") ];
    case "DATE":
      return [ _.property("raw.startDate") ];
    case "DIVISION":
      return [ _.property("ownerDivisionName") ];
    case "TYPE":
      return [ _.property("raw.type") ];
    case "USERS":
      return [ _.property("raw.name") ];
    default:
      return [(decoratedRecord, model) => decoratedRecord.id];
    }
  }
  else if (route === "/change_requests"){
    return [
      (decoratedRecord) => (parseInt(decoratedRecord.raw.codeNumber) || 0)
    ];
  }
  else if (route === "/issues"){
    return [
      (decoratedRecord) => (decoratedRecord.raw.progressKey === 6 ? 1 : 0),
      (decoratedRecord) => (decoratedRecord.raw.sourceKey),
      (decoratedRecord) => (parseInt(decoratedRecord.raw.codeNumber) || 0)
    ];
  }
  else {
    return [ _.property("raw.id") ];
  }
}

const referrals = (decoratedRecord, model) => {
  return (REFERRAL_ICON_RANKINGS[decoratedRecord.raw.referralIconKey] || 99);
};

const waittimes = (decoratedRecord, model) => {
  return (decoratedRecord.consultationWaitTimeKey || 99);
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

const REFERRAL_ICON_RANKINGS = {
  "green_check": 1,
  "blue_arrow": 5,
  "orange_warning": 3,
  "red_x": 6,
  "question_mark": 4,
  "none": 99,
  "orange_check": 2
};

export default sortIteratees;
