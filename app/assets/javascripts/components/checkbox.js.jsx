var Checkbox = React.createClass({
  getInitialState: function() {
    return { value: this.props.initialValue} ;
  },
  handleChange: function(event) {
    this.setState({ value: event.target.checked });
  },
  render: function() {
    return (
      <label>
        <span>{this.props.label}</span>
        <input type="checkbox" checked={this.state.value} onChange={this.handleChange}></input>
      </label>
    );
  }
});
