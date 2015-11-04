import hasBeenInitialized from "reducers/has_been_initialized";
import pageRenderedKey from "reducers/page_rendered_key";
import sortConfig from "reducers/filter_table/sort_config";
import _ from "lodash";

const contentCategoryId = _.partial(pageRenderedKey, "contentCategoryId");

module.exports = function(state = {}, action) {
  return {
    hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
    contentCategoryId: contentCategoryId(state.contentCategoryId, action),
    sortConfig: sortConfig(state.sortConfig, action),
  };
  // return {
  //   hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
  //   filterValues: filterValues(state.filterValues, action),
  //   filterVisibility: filterVisibility(state.filterVisibility, action),
  //   rows: rows(state.rows, action),
  //   isTableLoading: isTableLoading(state.isTableLoading, action)
  // };
}
