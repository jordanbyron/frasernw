var React = require("react");
var ReactDOM = require("react-dom");
var Redux = require("redux");
var Provider = require("react-redux").Provider;
var connect = require("react-redux").connect;
var _ = require("lodash");

var generateReducer = require("./reducers/top_level");

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
      React.createClass(
        this.props.component,
        {
          dispatch: this.props.store.dispatch,
          model: this.state
        }
      )
    );
  }
});

module.exports = function(config, initData) {
  $("document").ready(function() {

    // connect the component to redux
    var reducer = generateReducer(config.uiReducer);
    var store = Redux.createStore(reducer);
    var rootElement = $(config.domElementSelector)[0];
    var Component = require(`./react_components/${_.snakeCase(config.topLevelComponent)}`);

    // render the component
    ReactDOM.render(
      <Provider store={store} component={Component}/>,
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
