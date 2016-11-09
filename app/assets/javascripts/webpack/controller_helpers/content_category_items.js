import _ from "lodash";
import { route, routeParams, recordShownByRoute }
  from "controller_helpers/routing";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";
import { matchesTab, matchesPage } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";
import { preliminaryFilterKeys } from "controller_helpers/matches_preliminary_filters";
import * as preliminaryFilters from "controller_helpers/preliminary_filters";
import { navTabKey } from "controller_helpers/nav_tab_key";

const samePerPage = ((model) => {
  const _preliminaryFilters = preliminaryFilterKeys("contentItems").
    map((filterKey) => preliminaryFilters[filterKey])

  return _.values(model.app.contentItems).filter((item) => {
    return matchesPage(item, model) &&
      _preliminaryFilters.every((filter) => filter(item, model))
  });
}).pwPipe(memoizePerRender)

const contentCategoryItems = function(categoryId, model){
  return samePerPage(model).
    filter((item) => {
      return matchesTab(item, model, navTabKey("contentCategory", categoryId));
    });
};


export default contentCategoryItems;
