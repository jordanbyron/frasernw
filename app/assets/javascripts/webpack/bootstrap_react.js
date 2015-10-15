var React = require("react");
var Redux = require("redux");
var Provider = require("react-redux").Provider;
var connect = require("react-redux").connect;
var mapStateToProps = function(state) { return state; };
var mapDispatchToProps = function(dispatch) { return { dispatch: dispatch }; };

var TopLevelComponents = {
  SpecializationPage: require("./react_components/specialization_page"),
  ReferentsBySpecialty: require("./react_components/referents_by_specialty"),
  UsageReport: require("./react_components/usage_report")
}
var generateReducer = require("./reducers/top_level");
var StateMappers = {
  SpecializationPage: require("./state_mappers/specialization_page"),
  ReferentsBySpecialty: require("./state_mappers/referents_by_specialty"),
  UsageReport: require("./state_mappers/usage_report")
}

module.exports = function(config, initData) {
  $("document").ready(function() {

    // connect the component to redux
    var reducer = generateReducer(config.uiReducer);
    var store = Redux.createStore(reducer);
    var rootElement = $(config.domElementSelector)[0];
    var Component = TopLevelComponents[config.topLevelComponent];
    var mergeProps = StateMappers[config.stateMapper];

    var ConnectedComponent = connect(
      mapStateToProps,
      mapDispatchToProps,
      mergeProps
    )(Component);

    // render the component
    React.render(
      <Provider store={store}>
        {function() { return <ConnectedComponent />;} }
      </Provider>,
      rootElement
    );

    // integrate data we render on the ruby partial
    store.dispatch({
      type: "INITIALIZE_FROM_SERVER",
      initialState: initData
    })

    // integrate data stashed in localStorage ( or AJAX requested if necessary )
    window.pathways.globalDataLoaded.done(function(data) {
      store.dispatch({
        type: "INTEGRATE_LOCALSTORAGE_DATA",
        data: data
      });

      $("#heartbeat-loader-position").remove();
    })
  });
}
