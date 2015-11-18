var React = require("react");
var ReactDOM = require("react-dom");
var Redux = require("redux");
var Provider = require("react-redux").Provider;
var connect = require("react-redux").connect;
var _ = require("lodash");
var mapStateToProps = function(state) { return state; };
var mapDispatchToProps = function(dispatch) { return { dispatch: dispatch }; };
var getTopLevelProps = function(store, mapStateToProps, mapDispatchToProps, mergeProps) {
  return mergeProps(
    mapStateToProps(store.getState()),
    mapDispatchToProps(store.dispatch)
  );
};

var generateReducer = require("./reducers/top_level");

module.exports = function(config, initData) {
  $("document").ready(function() {

    // connect the component to redux
    var reducer = generateReducer(config.uiReducer);
    var store = Redux.createStore(reducer);
    var rootElement = $(config.domElementSelector)[0];
    var Component = require(`./react_components/${_.snakeCase(config.topLevelComponent)}`);
    var mergeProps = function(stateProps, dispatchProps) {
      return require(`./state_mappers/${_.snakeCase(config.stateMapper)}`)(
        stateProps,
        dispatchProps.dispatch,
        config.mapperConfig
      );
    }

    var ConnectedComponent = connect(
      mapStateToProps,
      mapDispatchToProps,
      mergeProps
    )(Component);

    // render the component
    ReactDOM.render(
      <Provider store={store}>
        <ConnectedComponent />
      </Provider>,
      rootElement
    );

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
      var topLevelProps =
        getTopLevelProps(store, mapStateToProps, mapDispatchToProps, mergeProps);

      topLevelProps.query &&
        topLevelProps.query() &&
        store.dispatch({ type: "MAKE_INITIAL_API_QUERY" });
    })
  });
}
