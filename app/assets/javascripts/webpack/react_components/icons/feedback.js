var React = require("react");
var buttonIsh = require("../../stylesets").buttonIsh

module.exports = React.createClass({
  handleOpenModal: function(e) {
    e.preventDefault();
    this.props.dispatch({
      type: "OPEN_FEEDBACK_MODAL",
      data: {
        id: this.props.record.id,
        itemType: this.props.itemType,
        title: this.props.record.title
      }
    });
  },
  render: function() {
    return(
      <i className="icon-bullhorn icon-blue"
        style={buttonIsh}
        onClick={this.handleOpenModal}/>
    );
  }
})
