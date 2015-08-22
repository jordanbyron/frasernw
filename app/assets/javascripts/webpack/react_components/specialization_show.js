var React = require("react");
var NavTabs = require("./nav_tabs");
var objectAssign = require("object-assign");
var contentClasses = {
  DataTable: require("./data_table")
}

module.exports = React.createClass({
  selectedPanel: function() {
    return this.props.panels[this.props.selectedPanel];
  },
  contentClass: function() {
    return contentClasses[this.selectedPanel().contentClass];
  },
  onTabClick: function(panelName) {
    return (event) => {
      this.props.dispatch({
        type: "SELECT_PANEL",
        panel: panelName
      })
    };
  },
  dispatchAction: function() {
    return (action) => {
      var decoratedAction = objectAssign(
        {},
        action,
        { panelKey: this.props.selectedPanel }
      );

      this.props.dispatch(decoratedAction)
    };
  },
  contentProps: function() {
    return objectAssign(
      {},
      this.selectedPanel().props,
      { dispatch: this.dispatchAction() }
    );
  },
  content: function() {
    // handle init
    if (this.selectedPanel() == undefined){
      return null;
    } else {
      return React.createElement(
        this.contentClass(),
        this.contentProps()
      );
    }
  },
  render: function() {
    console.log("NEW STATE:");
    console.log(this.props);
    return (
      <div>
        <NavTabs tabs={this.props.panelNav}
          onTabClick={this.onTabClick}/>
        { this.content() }
      </div>
    );
  }
});