var React = require("react");
var FilterGroup = require('./filter_group');

var Filters = React.createClass({
  propTypes: {
    title: React.PropTypes.string.isRequired,
    groups: React.PropTypes.arrayOf(React.PropTypes.object).isRequired
  },
  render: function() {
    return (
      <div className="well filter">
        <div className="title" key="title">{ this.props.title }</div>
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
      </div>
    );
  }
});

module.exports = Filters;
