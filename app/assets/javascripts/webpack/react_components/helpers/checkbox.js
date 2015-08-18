var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <label>
        <input
          type="checkbox"
          checked={this.props.value} onChange={this.props.onChange}
          className="checkbox"
        ></input>
        <span>{this.props.label}</span>
      </label>
    );
  }
});
