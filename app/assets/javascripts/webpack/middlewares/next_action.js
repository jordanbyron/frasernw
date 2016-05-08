import { requestData } from "action_creators";

const nextAction = store => next => action => {
  const result = next(action)

  switch(action.type){
  case "CHANGE_FILTER_VALUE":
    requestData(store.getState(), store.dispatch);
  }

  return result;
}

export default nextAction;
