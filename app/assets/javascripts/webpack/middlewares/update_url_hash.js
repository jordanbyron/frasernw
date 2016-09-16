import _ from "lodash";
import { uiKeysMirroredToUrlHash } from "url_hash_mirroring";
import { encode } from "utils/url_hash_encoding";

const updateUrlHash = store => next => action => {
  const result = next(action)

  if (_.includes(TRIGGERING_ACTION_TYPES, action.type)){
    window.pathways.parseUrlOnHashChange = false;
    window.location.hash = _.pick(store.getState().ui, uiKeysMirroredToUrlHash).
      pwPipe(encode)

    // we need to allow a beat for our "onhashchange" event to fire
    // and find the flag is still false
    setTimeout(() => {
      window.pathways.parseUrlOnHashChange = true;
    }, 0)
  }

  return result;
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
