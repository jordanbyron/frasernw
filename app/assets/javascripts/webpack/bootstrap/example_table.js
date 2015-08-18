var React = require("react");
var Redux = require("redux");
var Provider = require("react-redux").Provider;
var connect = require("react-redux").connect;
var reducer = require("../reducers/example_table");
var ExampleTable = require("../react_components/partials/example_table");

var store = Redux.createStore(reducer);

var ConnectedExampleTable = connect(
  function(state){
    return state;
  }
)(ExampleTable);

module.exports = function() {
  $("document").ready(function() {
    var rootElement = $('#example_table')[0];
    React.render(
      <Provider store={store}>
        {function() { return <ConnectedExampleTable />;} }
      </Provider>,
      rootElement
    );

    // make the store available on the window so we can dispatch
    // initialization action to it
    window.pathways = window.pathways || {};
    window.pathways.exampleTableStore = store;
  });
};
