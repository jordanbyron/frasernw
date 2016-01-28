import _ from "lodash";
import pageRenderedKey from 'reducers/page_rendered_key';
import hasBeenInitialized from "../has_been_initialized";

const divisionIds = _.partial(pageRenderedKey, "divisionIds");
const canHide = _.partial(pageRenderedKey, "canHide");

const latestUpdates = (state, action) => {
  switch(action.type) {
  case "INTEGRATE_PAGE_RENDERED_DATA":
    return action.initialState.ui.latestUpdates;
  case "TOGGLE_UPDATE_VISIBILITY":
    const toOmit = _.find(state, _.matches(action.update))

    return _.without(state, toOmit)
  default:
    return state;
  }
};

module.exports = function(state = {}, action) {
  return _.assign(
    {},
    state,
    {
      hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
      latestUpdates: latestUpdates(state.latestUpdates, action),
      divisionIds: divisionIds(state.divisionIds, action),
      canHide: canHide(state.canHide, action)
    }
  );
};
