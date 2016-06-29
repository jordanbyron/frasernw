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
        modalState={this.modalState()}
        title={this.title()}
        id={this.id()}
      />
    );
  }
});

const FeedbackModal = React.createClass({
  propTypes: {
    id: React.PropTypes.number,
    itemType: React.PropTypes.string,
    title: React.PropTypes.string,
    state: React.PropTypes.string
  },
  modalStyle: {
    position: "fixed",
    top: "25%",
    left: "25%",
    width: "50%",
    backgroundColor: "white",
    padding: "30px",
    boxShadow: "2px 2px 8px #888",
    zIndex: "999"
  },
  submitText: function() {
    if (this.props.modalState === "SUBMITTING"){
      return "Submitting";
    } else {
      return "Submit";
    }
  },
  handleSubmit: function(e) {
    e.preventDefault();

    this.props.handleSubmit(this.refs.feedback.value.trim());
  },
  form: function() {
    return(
      <div style={this.modalStyle}>
        <div className="inner">
          <form onSubmit={this.handleSubmit}>
            <label style={{fontWeight: "bold"}}>
              <span>Please provide us with any comments about </span>
              <span className="feedback_item_title">{ this.props.title }</span>
              <textarea
                ref="feedback"
                style={{width: "100%", height: "150px", marginTop: "10px"}}
              ></textarea>
            </label>
            <div className="form-actions">
              <input type="submit"
                className="btn btn-primary"
                value={ this.submitText() }
              />
              <a className="btn btn-danger"
                onClick={this.props.handleClose}
                style={{marginLeft: "2px"}}
              >Cancel</a>
            </div>
          </form>
        </div>
      </div>
    );
  },
  postSubmit: function() {
    return(
      <div style={this.modalStyle}>
        <div className="inner">
          <h2>Thank you!</h2>
          <p className="space no_indent">
            {
              `Thank you for providing feedback on ${this.props.title}.  ` +
              "Your contributions help make Pathways a valuable resource " +
              "for the community."
            }
          </p>
          <p className="space no_indent">
            {
              "We will review your feedback in the near future " +
              "and take action as necessary."
            }
          </p>
          <a className="btn btn-primary"
            onClick={this.props.handleClose}
            style={{marginTop: "10px"}}
          >Close</a>
        </div>
      </div>
    )
  },
  render: function(){
    const showForm = this.props.modalState === "PRE_SUBMIT" ||
      this.props.modalState === "SUBMITTING";

    if(showForm){
      return this.form();
    } else if (this.props.modalState === "POST_SUBMIT") {
      return this.postSubmit();
    } else {
      return null;
    }
  }
})

export default FeedbackModalController;
