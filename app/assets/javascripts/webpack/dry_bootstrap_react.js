import Template from "controllers/template";
import Provider from "provider";
import createLogger from "redux-logger";
import { createStore, applyMiddleware } from "redux";
import ReactDOM from "react-dom";
import rootReducer from "dry_reducers/root_reducer";
import React from "react";

let middlewares = [];
const logger = createLogger();
middlewares.push(logger);

const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
const store = createStoreWithMiddleware(rootReducer);

const dryBootstrapReact = function() {
  $(document).ready(function() {
    ReactDOM.render(
      <Provider childKlass={Template} store={store}/>,
      document.getElementById("react_root--template")
    )
  })
}

export default dryBootstrapReact;
