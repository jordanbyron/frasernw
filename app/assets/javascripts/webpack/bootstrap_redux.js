var React = require("react");
var Redux = require("redux");
var Provider = require("react-redux").Provider;
var connect = require("react-redux").connect;
var mapStateToProps = function(state) { return state; };
var mapDispatchToProps = function(dispatch) { return { dispatch: dispatch }; };

var TopLevelComponents = {
  SpecializationPage: require("./react_components/specialization_page"),
  ReferentsBySpecialty: require("./react_components/referents_by_specialty")
}
var Reducers = {
  SpecializationPage: require("./reducers/specialization_page"),
  ReferentsBySpecialty: require("./reducers/referents_by_specialty")
}
var StateMappers = {
  SpecializationPage: require("./state_mappers/specialization_page"),
  ReferentsBySpecialty: require("./state_mappers/referents_by_specialty"),
}

module.exports = function(config) {
  var reducer = Reducers[config.reducer];
  var store = Redux.createStore(reducer);
  var rootElement = $(config.domElementSelector)[0];
  var Component = TopLevelComponents[config.topLevelComponent];
  var mergeProps = StateMappers[config.stateMapper];

  var ConnectedComponent = connect(
    mapStateToProps,
    mapDispatchToProps,
    mergeProps
  )(Component);

  React.render(
    <Provider store={store}>
      {function() { return <ConnectedComponent />;} }
    </Provider>,
    rootElement
  );

  return store;
};
