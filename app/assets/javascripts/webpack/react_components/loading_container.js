var React = require("react");

module.exports = React.createClass({
  propTypes: {
    isLoading: React.PropTypes.bool
  },
  render: function() {
    if (this.props.isLoading){
      return(
        <div>
          <div id="heartbeat-loader-position">
            <div className="heartbeat-loader"/>
          </div>
        </div>
      );
    } else {
      return this.props.renderChildren(this.props.childrenProps);
    }
  }
})