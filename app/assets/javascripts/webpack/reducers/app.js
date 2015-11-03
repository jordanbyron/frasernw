var _ = require("lodash");

var favorites = function(state = {}, action) {
  switch(action.type) {
  case "FAVORITED_ITEM":
    return _.assign(
      {},
      state,
      { [action.itemType]: state[action.itemType].concat(action.id) }
    );
  case "UNFAVORITED_ITEM":
    return _.assign(
      {},
      state,
      { [action.itemType]: _.without(state[action.itemType], action.id) }
    );
  default:
    return state;
  }
}

var currentUser = function(state = {}, action) {
  return _.assign(
    {},
    state,
    { favorites: favorites(state.favorites, action) }
  )
}

module.exports = function(state = {}, action) {
  switch(action.type){
  case "INTEGRATE_LOCALSTORAGE_DATA":
    return _.assign(
      {},
      state,
      action.data
    );
  case "INTEGRATE_PAGE_RENDERED_DATA":
    return action.initialState.app;
  default:
    return _.assign(
      {},
      state,
      { currentUser: currentUser(state.currentUser, action) }
    )
  }
}
