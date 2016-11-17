import _ from "lodash";
import { route } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import { memoizePerRender } from "utils";

export const selectedTableHeadingKey = ((model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "selectedTableHeading", "key"],
    defaultHeadingKey(model)
  )
})

export const canSelectSort = ((model) => {
  return !_.includes(["/issues", "/change_requests"], route);
})

const defaultHeadingKey = ((model) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    return "REFERRALS";
  }
  else if (collectionShownName(model) === "contentItems") {
    return "TITLE";
  }
  else if (route === "/reports/page_views_by_user"){
    return "PAGE_VIEWS";
  }
  else if (route === "/reports/profiles_by_specialty"){
    return "SPECIALTY";
  }
  else if (route === "/news_items"){
    return "DATE";
  }
})

export const headingArrowDirection = ((model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "selectedTableHeading", "direction"],
    "DOWN"
  );
})
