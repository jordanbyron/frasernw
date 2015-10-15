var React = require("react");
var LoadingContainer = require("./loading_container");

module.exports = React.createClass({
  renderChildren: function(props) {
    return(
      <div className="content-wrapper">
      </div>
    );
  },
  render: function() {
    return(
      <LoadingContainer
        isLoading={true}
        renderChildren={this.renderChildren.bind(null, this.props)}
      />
    )
  }
})
