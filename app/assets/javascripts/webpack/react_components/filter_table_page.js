var React = require("react");
var LoadingContainer = require("./loading_container");
var Panels = require("./panels");
var FeedbackModal = require("./feedback_modal");

module.exports = React.createClass({
  propTypes: {
    isLoading: React.PropTypes.bool,
    panels: React.PropTypes.array,
    selectedPanel: React.PropTypes.object,
    dispatch: React.PropTypes.func
  },
  renderContents: function(props) {
    return(
      <Panels
        tabs={props.tabs}
        selectedPanel={props.selectedPanel}
        dispatch={props.dispatch}
      />
    );
  },
  render: function() {
    // console.log("TRANSFORMED_PROPS:");
    // console.log(this.props);
    return(
      <div>
        <LoadingContainer isLoading={this.props.isLoading}
          renderContents={this.renderContents.bind(null, this.props)}
        />
        <FeedbackModal
          dispatch={this.props.dispatch}
          {...this.props.feedbackModal}
        />
      </div>
    );
  }
})
