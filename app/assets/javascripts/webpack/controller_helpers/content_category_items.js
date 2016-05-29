import _ from "lodash";
import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { matchesTab, matchesRoute } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";

const samePerPage = ((model) => {
  return _.values(model.app.contentItems).filter((item) => {
    return matchesRoute(matchedRoute(model), recordShownByPage(model), item) &&
      _.intersection(
        item.availableToDivisionIds,
        model.app.currentUser.divisionIds
      ).pwPipe(_.any)
  });
}).pwPipe(memoizePerRender)

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
