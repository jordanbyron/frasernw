var React = require("react");
import SidebarWell from "./sidebar_well";
var FilterGroup = require('./filter_group');

var Filters = React.createClass({
  propTypes: {
    title: React.PropTypes.string.isRequired,
    groups: React.PropTypes.arrayOf(React.PropTypes.object).isRequired
  },
  render: function() {
    return (
      <SidebarWell title={this.props.title}>
        {
          this.props.groups.map((group, index) => {
            return(
              <FilterGroup
                {...group}
                key={index}
                dispatch={this.props.dispatch}
              />
            );
          })
        }
      </SidebarWell>
    );
  }
});

module.exports = Filters;
