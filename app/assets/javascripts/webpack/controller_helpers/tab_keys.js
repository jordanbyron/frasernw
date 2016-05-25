import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";
import { memoize } from "utils";

export const defaultTab = memoize(
  matchedRoute,
  matchedRouteParams,
  (model) => model.app.divisions,
  (model) => model.app.currentUser.divisionIds,
  (matchedRoute, matchedRouteParams, divisions, currentUserDivisionIds) => {
    switch(matchedRoute){
    case "/specialties/:id":
      return divisions[currentUserDivisionIds[0]].
        openToSpecializationPanel[matchedRouteParams.id];
    case "/areas_of_practice/:id":
      return { type: "specialists" };
    default:
      return { type: "only" };
    }
  }
)

export const selectedTabKey = memoize(
  (model) => model.ui.location.query.tabKey,
  defaultTab,
  (userSelectedTab, defaultTab) => {
    return (userSelectedTab ||
      tabKey(defaultTab.type, defaultTab.id));
  }
);

const extractId = (tabKey) => {
  return parseInt(tabKey.match(/\d+/));
}

export function recordShownByTab(model){
  if(selectedTabKey(model).includes("contentCategory")){
    return model.app.contentCategories[extractId(selectedTabKey(model))];
  }
}

export function tabKey(type, id) {
  if (id) {
    return (type + id);
  } else {
    return type;
  }
};
