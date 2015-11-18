var React = require("react");

module.exports = React.createClass({
  propTypes: {
    isLoading: React.PropTypes.bool
  },
  render: function() {
    if (this.props.isLoading && (this.props.showHeart === undefined || this.props.showHeart)){
      return(
        <div style={{position: "relative", minHeight: this.props.minHeight}}>
          <div id="heartbeat-loader-position-noremove" style={{position: "absolute"}}>
            <div className="heartbeat-loader"/>
          </div>
        </div>
      );
    } else if (this.props.isLoading) {
      return null;
    } else {
      return this.props.renderContents();
    }
  }
})
