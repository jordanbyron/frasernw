var React = require("react");

module.exports = React.createClass({
  getInitialState: function() {
    return { value: this.props.initialValue} ;
  },
  handleChange: function(event) {
    this.setState({ value: event.target.value });
  },
  render: function() {
    return (
      <label>
        <span>{this.props.label}</span>
        <select value={this.state.value} onChange={this.handleChange}>
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
