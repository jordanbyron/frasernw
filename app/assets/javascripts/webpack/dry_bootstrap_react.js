import TemplateController from "controllers/template";
import Provider from "provider";
import createLogger from "redux-logger";
import { createStore, applyMiddleware } from "redux";
import ReactDOM from "react-dom";
import rootReducer from "dry_reducers/root_reducer";
import React from "react";

import { requestInitialData } from "action_creators";

let middlewares = [];
const logger = createLogger();
middlewares.push(logger);

const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
const store = createStoreWithMiddleware(rootReducer);

const dryBootstrapReact = function() {
  $(document).ready(function() {
    ReactDOM.render(
      <Provider childKlass={TemplateController} store={store}/>,
      document.getElementById("react_root--template")
    )

    requestInitialData(store.getState(), store.dispatch);
  })
}

export default dryBootstrapReact;
