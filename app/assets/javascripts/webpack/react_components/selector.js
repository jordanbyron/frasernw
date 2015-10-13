var React = require("react");

module.exports = React.createClass({
  onChange: function(event) {
    return this.props.onChange(event, this.props.changeKey);
  },
  render: function() {
    return (
      <label>
        <span>{this.props.label}</span>
        <select value={this.props.value}
          style={this.props.style}
          onChange={this.onChange}>
          {
            this.props.options.map(function(option) {
              return (
                <option key={option.key}
                  value={option.key}
                >
                  {option.label}
                </option>
              );
            })
          }
        </select>
      </label>
    );
  }
});
