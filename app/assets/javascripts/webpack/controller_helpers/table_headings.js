import _ from "lodash";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

export const selectedTableHeadingKey = (model) => {
  return _.get(
    model,
    ["ui", "selectedTableHeading", "key"],
    defaultHeadingKey(model)
  )
}

const defaultHeadingKey = (model) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    return "REFERRALS";
  }
  else if (collectionShownName(model) === "contentItems") {
    return "TITLE";
  }
  else if (matchedRoute(model) === "/reports/pageviews_by_user"){
    return "PAGE_VIEWS";
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty"){
    return "SPECIALTY";
  }
}

export const headingArrowDirection = (model) => {
  return _.get(model, ["ui", "selectedTableHeading", "direction"], "DOWN");
}
