var React = require("react");

module.exports = React.createClass({
  propTypes: {
    isLoading: React.PropTypes.bool
  },
  render: function() {
    if (this.props.isLoading){
      console.log("loading");

      return(
        <div style={{position: "relative", minHeight: this.props.minHeight}}>
          <div id="heartbeat-loader-position-noremove" style={{position: "absolute"}}>
            <div className="heartbeat-loader"/>
          </div>
        </div>
      );
    } else {
      return this.props.renderChildren();
    }
  }
})
