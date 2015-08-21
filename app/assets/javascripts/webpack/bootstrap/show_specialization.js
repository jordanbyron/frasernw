var React = require("react");
var Redux = require("redux");
var Provider = require("react-redux").Provider;
var connect = require("react-redux").connect;
var reducer = require("../reducers/specialization_show");
var Component =
  require("../react_components/specialization_show");

var store = Redux.createStore(reducer);

var ConnectedComponent = connect(
  function(state){
    return state;
  }
)(Component);

module.exports = function() {
  $("document").ready(function() {
    var rootElement = $('#show_specialization')[0];
    React.render(
      <Provider store={store}>
        {function() { return <ConnectedComponent />;} }
      </Provider>,
      rootElement
    );

    // make the store available on the window so we can dispatch
    // initialization action to it
    window.pathways = window.pathways || {};
    window.pathways.exampleTableStore = store;
  });
};
