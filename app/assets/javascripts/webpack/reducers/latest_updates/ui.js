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
    const toUpdate = _.find(state, _.matches(action.update))
    const toUpdateIndex = _.findIndex(state, _.matches(action.update))
    const updated = _.assign(
      {},
      toUpdate,
      { hidden: action.hide }
    );

    const newUpdates = _.clone(state);

    newUpdates[toUpdateIndex] = updated;

    return newUpdates;
  default:
    return state;
  }
};

const showHiddenUpdates = (state, action) => {
  switch(action.type) {
  case "TOGGLE_HIDDEN_UPDATE_VISIBILITY":
    return !state;
  default:
    return state;
  }
}

module.exports = function(state = {}, action) {
  return _.assign(
    {},
    state,
    {
      hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
      latestUpdates: latestUpdates(state.latestUpdates, action),
      divisionIds: divisionIds(state.divisionIds, action),
      canHide: canHide(state.canHide, action),
      showHiddenUpdates: showHiddenUpdates(state.showHiddenUpdates, action)
    }
  );
};
