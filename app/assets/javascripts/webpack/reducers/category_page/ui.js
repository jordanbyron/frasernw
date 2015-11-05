import hasBeenInitialized from "reducers/has_been_initialized";
import pageRenderedKey from "reducers/page_rendered_key";
import sortConfig from "reducers/filter_table/sort_config";
import filterValues from "reducers/filter_table/filter_values";
import filterGroupVisibility from "reducers/filter_table/filter_group_visibility";
import feedbackModal from "reducers/feedback_modal";
import reducedView from "reducers/filter_table/reduced_view";
import _ from "lodash";

const contentCategoryId = _.partial(pageRenderedKey, "contentCategoryId");
const pageType = _.partial(pageRenderedKey, "pageType");

export default function(state = {}, action) {
  console.log(action);
  return {
    hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
    contentCategoryId: contentCategoryId(state.contentCategoryId, action),
    pageType: pageType(state.pageType, action),
    sortConfig: sortConfig(state.sortConfig, action),
    filterGroupVisibility: filterGroupVisibility(state.filterGroupVisibility, action),
    filterValues: filterValues(state.filterValues, action),
    feedbackModal: feedbackModal(state.feedbackModal, action),
    reducedView: reducedView(state.reducedView, action),
  };
}
