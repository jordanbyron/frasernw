import ReactDOM from "react-dom";
import React from "react";
import { createStore, applyMiddleware } from 'redux';
import createBrowserHistory from 'history/lib/createBrowserHistory'
import { useQueries } from 'history';
import createLogger from 'redux-logger';
import { locationChanged } from 'action_creators';
import { Routes, matchedRoute, routeParams } from 'routes';
import { Deferred } from 'utils';
import BodyController from "controllers/body";
import _ from 'lodash';
import rootReducer from "reducers/top_level";

// setup middleware

let middlewares = []

const logger = createLogger();
middlewares.push(logger);

const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
const store = createStoreWithMiddleware(rootReducer);

// only want to render the component when the store has a valid location

const stateReadyForRender = new Deferred();
store.subscribe(() => {
  if (store.getState().ui.location) {
    stateReadyForRender.resolve();
  }
});

// setup history
// think of this as middleware between the url bar and redux

const browserHistory = useQueries(createBrowserHistory)();
browserHistory.listen((location) => {
  const _matchedRoute = matchedRoute(location);

  store.dispatch(locationChanged({
    route: _matchedRoute,
    queryParams: location.query,
    routeParams: routeParams(location.pathname, _matchedRoute)
  }));
});

const Provider = React.createClass({
  getInitialState: function() {
    return this.props.store.getState();
  },
  componentWillMount: function() {
    this.props.store.subscribe(() => {
      this.setState(this.props.store.getState())
    });
  },
  render: function() {
    return(
      <BodyController
        dispatch={this.props.store.dispatch}
        model={this.state}
      />
    );
  }
});

module.exports = function(config, initData) {
  $("document").ready(function() {

    // connect the component to redux
    var rootElement = $(config.domElementSelector)[0];

    stateReadyForRender.promise.then(() => {
      ReactDOM.render(
        <Provider store={store} component={BodyController}/>,
        rootElement
      );
    }).catch((err) => { setTimeout(() => { throw err; }); });

    // integrate data we render on the ruby partial
    store.dispatch({
      type: "INTEGRATE_PAGE_RENDERED_DATA",
      initialState: initData
    })

    // integrate data stashed in localStorage ( or AJAX requested if necessary )
    // this is 'global' data that is used by many views
    window.pathways.globalDataLoaded.done(function(data) {
      store.dispatch({
        type: "INTEGRATE_LOCALSTORAGE_DATA",
        data: data
      });

      $("#heartbeat-loader-position").remove();

      // use our computed top level props to make the initial api query

      // TODO!
      // var topLevelProps =
      //   getTopLevelProps(store, mapStateToProps, mapDispatchToProps, mergeProps);
      //
      // topLevelProps.query &&
      //   topLevelProps.query() &&
      //   store.dispatch({ type: "MAKE_INITIAL_API_QUERY" });
    })
  });
}
