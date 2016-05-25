import _ from "lodash";
import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { matchesTab, matchesRoute } from "controller_helpers/collection_shown";
import { memoize } from "utils";

const samePerPage = memoize(
  (model) => _.values(model.app.contentItems),
  (model) => model.app.currentUser.divisionIds,
  matchedRoute,
  recordShownByPage,
  (contentItems, divisionIds, matchedRoute, recordShownByPage) => {
    return contentItems.filter((item) => {
      return matchesRoute(matchedRoute, recordShownByPage, item) &&
        _.intersection(
          item.availableToDivisionIds,
          divisionIds
        ).pwPipe(_.any)
    });
  }
);

const contentCategoryItems = function(categoryId, model){
  return samePerPage(model).
    filter((item) => {
      return matchesTab(
        item,
        model.app.contentCategories,
        `contentCategory${categoryId}`
      );
    });
};


export default contentCategoryItems;
