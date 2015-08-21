var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <div className="row">
        <div className="span8">
          {this.props.main}
        </div>
        <div className="span4">
          {this.props.sidebar}
        </div>
      </div>
    );
  }
});
