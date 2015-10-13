var React = require("react");

module.exports = React.createClass({
  onChange: function(event) {
    return this.props.onChange(event, this.props.changeKey);
  },
  label: function() {
    if (this.props.label) {
      return (<span>{this.props.label}</span>);
    } else {
      return null;
    }
  },
  render: function() {
    return (
      <label>
        { this.label() }
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
