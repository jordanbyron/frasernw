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
          onChange={this.onChange}>
          {
            this.props.options.map(function(option, i) {
              return (
                <option key={i} value={option.key}>{option.label}</option>
              );
            })
          }
        </select>
      </label>
    );
  }
});
