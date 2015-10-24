var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  propTypes: {
    anyResults: React.PropTypes.bool,
    isVisible: React.PropTypes.bool,
    text: React.PropTypes.string,
    dispatch: React.PropTypes.func
  },
  handleClearFilters: function() {
    this.props.dispatch({
      type: "CLEAR_FILTERS"
    });
  },
  className: function() {
    if (this.props.anyResults) {
      return "filter-phrase";
    } else {
      return "filter-phrase none";
    }
  },
  render: function() {
    if (this.props.isVisible) {
      return(
        <div className={this.className()} style={{display: "block"}}>
          <span>{ this.props.text + ".   " }</span>
          <a onClick={this.handleClearFilters} style={buttonIsh}>
            Clear all filters.
          </a>
        </div>
      );
    } else {
      return null;
    }
  }
})
