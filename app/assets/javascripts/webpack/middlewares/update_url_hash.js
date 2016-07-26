import _ from "lodash";
import newUrlHash from "reducers/url_hash";

const updateUrlHash = store => next => action => {
  if (_.includes(TRIGGERING_ACTION_TYPES, action.type)) {
    window.location.hash = JSON.stringify(
      newUrlHash(store.getState().ui, action)
    );
    window.pathways.urlHashFlushed = false;
  }

  return next(action);
};

const TRIGGERING_ACTION_TYPES = [
  "TOGGLE_ROW_EXPANSIONS",
  "SET_PAGE",
  "TOGGLE_SPECIALIZATION_FILTER",
  "TOGGLE_UNFOCUSED_PROCEDURE_VISIBILITY",
  "TOGGLE_FILTER_GROUP_EXPANSION",
  "SELECT_REDUCED_VIEW",
  "SORT_BY_HEADING",
  "CHANGE_FILTER_VALUE",
  "UPDATE_CITY_FILTERS",
  "CLEAR_FILTERS",
  "TAB_CLICKED"
];



export default updateUrlHash;
