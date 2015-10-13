var React = require("react");
var NavTabs = require("./nav_tabs");
var _ = require("lodash");
var COMPONENTS = {
  FilterTable: require("./filter_table"),
  InlineArticles: require("./inline_articles")
};

module.exports = React.createClass({
  propTypes: {
    tabs: React.PropTypes.array,
    selectedPanel: React.PropTypes.shape({
      key: React.PropTypes.string,
      contentComponent: React.PropTypes.string,
      contentComponentPropts: React.PropTypes.object
    }),
    dispatch: React.PropTypes.func.isRequired
  },
  navTabProps: function() {
    var component = this;

    return {
      selectedTab: this.props.selectedPanel.key,
      tabs: this.props.tabs.map((panel) => {
        return {
          label: panel.label,
          key: panel.key
        };
      }),
      onTabClick: function(key) {
        return (event) => {
          component.props.dispatch({
            type: "SELECT_PANEL",
            panel: key
          })
        };
      }
    };
  },
  decorateDispatch: function(panelKey) {
    return (action) => {
      this.props.dispatch(
        _.assign(
          { panelKey: panelKey, reducer: this.props.selectedPanel.contentComponent },
          action
        )
      );
    };
  },
  render: function() {
    return(
      <div>
        <NavTabs {...this.navTabProps()}/>
        <div className="content-wrapper">
          <div className="tab-content">
            {
              React.createElement(
                COMPONENTS[this.props.selectedPanel.contentComponent],
                _.assign(
                  {},
                  this.props.selectedPanel.contentComponentProps,
                  { dispatch: this.decorateDispatch(this.props.selectedPanel.key) }
                )
              )
            }
          </div>
        </div>
      </div>
    );
  }
})
