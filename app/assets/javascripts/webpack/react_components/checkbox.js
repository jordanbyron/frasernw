var React = require("react");

module.exports = React.createClass({
  onChange: function(event) {
    return this.props.onChange(event, this.props.changeKey);
  },
  render: function() {
    return (
      <label style={this.props.labelStyle}>
        <input
          type="checkbox"
          checked={this.props.value} onChange={this.onChange}
          className="checkbox"
          style={this.props.style}
        ></input>
        <span>{this.props.label}</span>
      </label>
    );
  }
});
