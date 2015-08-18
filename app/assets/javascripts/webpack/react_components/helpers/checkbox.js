var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <label>
        <span>{this.props.label}</span>
        <input type="checkbox" checked={this.props.value} onChange={this.props.onChange}></input>
      </label>
    );
  }
});
