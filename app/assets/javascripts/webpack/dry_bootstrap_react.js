import TemplateController from "controllers/template";
import Provider from "provider";
import createLogger from "redux-logger";
import nextAction from "middlewares/next_action";
import { createStore, applyMiddleware } from "redux";
import ReactDOM from "react-dom";
import rootReducer from "dry_reducers/root_reducer";
import React from "react";

import { requestData, parseRenderedData } from "action_creators";

let middlewares = [];
const logger = createLogger();
middlewares.push(logger);
middlewares.push(nextAction);

const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
const store = createStoreWithMiddleware(rootReducer);

const dryBootstrapReact = function() {
  $(document).ready(function() {
    var target = document.getElementById("react_root--template");


    if (target) {
      ReactDOM.render(
        <Provider childKlass={TemplateController} store={store}/>,
        target
      )
      requestData(store.getState(), store.dispatch);
      parseRenderedData(store.dispatch);
    }
  })
}

export default dryBootstrapReact;
