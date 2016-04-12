import FeedbackModal from 'helpers/feedback_modal';
import React from 'react';

const FeedbackModalController = React.createClass({
  componentDidMount: function() {
    window.pathways.feedbackModal = this;
  },
  handleClose: function(e){
    e.preventDefault();
    this.setState({modalState: "CLOSED"})
  },
  getInitialState: function() {
    return {};
  },
  handleSubmit: function(comment){
    if(!comment){
      return;
    } else {
      $.post("/feedback_items", {
        feedback_item: {
          item_id: this.id(),
          item_type: this.itemType(),
          feedback: comment
        }
      }).success(() => {
        this.setState({modalState: "POST_SUBMIT"});
      })

      this.setState({modalState: "SUBMITTING"});
    }
  },
  title: function() {
    return this.state.title || "Nothing";
  },
  itemType: function() {
    return this.state.itemType || "NULL";
  },
  id: function() {
    return this.state.id || 0;
  },
  modalState: function() {
    return this.state.modalState || "CLOSED";
  },
  render: function() {
    return(
      <FeedbackModal
        handleSubmit={this.handleSubmit}
        handleClose={this.handleClose}
        state={this.modalState()}
        title={this.title()}
        id={this.id()}
      />
    );
  }
})

export default FeedbackModalController;
