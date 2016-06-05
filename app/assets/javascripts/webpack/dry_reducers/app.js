import _ from "lodash";

const app = (model = {}, action) => {
  switch(action.type){
  case "PARSE_RENDERED_DATA":
    if(action.data.app){
      return _.assign(
        {},
        model,
        action.data.app
      );
    }
    else {
      return model;
    }
  case "INTEGRATE_LOCALSTORAGE_DATA":
    return _.assign(
      {},
      model,
      action.data
    );
  case "UNFAVORITED_ITEM":
    return _.assign(
      {},
      model,
      { currentUser: currentUser(model.currentUser, action) }
    )
  case "FAVORITED_ITEM":
    return _.assign(
      {},
      model,
      { currentUser: currentUser(model.currentUser, action) }
    )
  default:
    return model;
  }
}

const favorites = function(model = {}, action) {
  switch(action.type) {
  case "FAVORITED_ITEM":
    return _.assign(
      {},
      model,
      { [action.itemType]: model[action.itemType].concat(action.id) }
    );
  case "UNFAVORITED_ITEM":
    return _.assign(
      {},
      model,
      { [action.itemType]: _.without(model[action.itemType], action.id) }
    );
  default:
    return model;
  }
}

const currentUser = function(model = {}, action) {
  switch(action.type) {
  case "FAVORITED_ITEM":
    return _.assign(
      {},
      model,
      { favorites: favorites(model.favorites, action) }
    )
  case "UNFAVORITED_ITEM":
    return _.assign(
      {},
      model,
      { favorites: favorites(model.favorites, action) }
    )
  default:
    return model;
  }
}

export default app;
