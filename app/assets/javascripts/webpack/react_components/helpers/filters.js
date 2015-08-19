var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <div className="well filter">
        <div className="title">{ this.props.title }</div>
        { React.Children.map(this.props.children, (child) => child) }
      </div>
    );
  }
});
