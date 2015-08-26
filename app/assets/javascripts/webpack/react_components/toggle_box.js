var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  iconStyle: {
    background: "transparent url(/img/filtering-divider.png) 0% 50% repeat-y",
    paddingLeft: "10px"
  },
  toggleIconClass: function() {
    if (this.props.open) {
      return "icon-minus";
    } else {
      return "icon-plus";
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
          onClick={this.props.handleToggle}
          style={buttonIsh}
        >
          <span>{ this.props.title }</span>
          <i className={this.toggleIconClass() + " filter_group__toggle"}
            style={this.iconStyle}></i>
        </div>
        { this.contents() }
      </div>
    );
  }
});
