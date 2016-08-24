import { requestDynamicData } from "action_creators";

const nextAction = store => next => action => {
  const result = next(action)

  if (_.includes([ "CHANGE_FILTER_VALUE", "PARSE_URL_HASH"], action.type)){
    requestDynamicData(store.getState(), store.dispatch);
  }

  return result;
}

export default nextAction;
