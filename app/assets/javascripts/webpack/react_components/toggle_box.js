var React = require("react");

module.exports = React.createClass({
  toggleIconClass: function() {
    if (this.props.open) {
      return "icon-plus";
    } else {
      return "icon-minus";
    }
  },
  contents: function() {
    if (this.props.open){
      return (
        <div className="filter_group__filters">
          {
            React.Children.map(this.props.children, (child) => child)
          }
        </div>
      );
    } else {
      return null;
    }
  },
  render: function() {
    return (
      <div>
        <div className="filter_group__title open"
          onClick={this.props.handleToggle}>
          <span>{ this.props.title }</span>
          <i className={"icon-plus filter_group__toggle"}></i>
        </div>
        { this.contents() }
      </div>
    );
  }
});