import _ from "lodash";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { selectedTabKey } from "controller_helpers/tab_keys";
import { memoizePerRender } from "utils";

export const selectedTableHeadingKey = ((model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "selectedTableHeading", "key"],
    defaultHeadingKey(model)
  )
})

const defaultHeadingKey = ((model) => {
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
  else if (matchedRoute(model) === "/news_items"){
    return "DATE";
  }
  else if (matchedRoute(model) === "/issues") {
    return "ISSUE_ID";
  }
})

export const headingArrowDirection = ((model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "selectedTableHeading", "direction"],
    "DOWN"
  );
})
