import React from 'react';
import _ from "lodash";
import { submitFeedback, closeFeedbackModal } from "action_creators";

const FeedbackModal = ({model, dispatch}) => {
  if(_.includes(["PRE_SUBMIT", "SUBMITTING"], modalState(model))){
    return(
      <PreSubmitModal model={model} dispatch={dispatch}/>
    );
  }
  else if (modalState(model) === "POST_SUBMIT"){
    return(
      <PostSubmitModal model={model} dispatch={dispatch}/>
    );
  }
  else {
    return <noscript/>
  }
}

const modalState = (model) => {
  return _.get(
    model,
    ["ui", "feedbackModal", "state" ],
    "CLOSED"
  );
}

const PreSubmitModal = React.createClass({
  handleSubmit: function(e) {
    e.preventDefault();

    submitFeedback(
      this.props.dispatch,
      this.props.model,
      this.refs.feedback.value.trim()
    );
  },
  render: function() {
    return(
      <div style={modalStyle}>
        <div className="inner">
          <form onSubmit={this.handleSubmit}>
            <label style={{fontWeight: "bold"}}>
              <span>Please provide us with any comments about </span>
              <span className="feedback_item_title">{ title(this.props.model) }</span>
              <textarea
                ref="feedback"
                style={{width: "100%", height: "150px", marginTop: "10px"}}
              ></textarea>
            </label>
            <div className="form-actions">
              <input type="submit"
                className="btn btn-primary"
                value={ submitText(this.props.model) }
              />
              <a className="btn btn-danger"
                onClick={_.partial(handleClose, this.props.dispatch)}
                style={{marginLeft: "2px"}}
              >Cancel</a>
            </div>
          </form>
        </div>
      </div>
    );
  }
});

const handleClose = (dispatch, e) => {
  e.preventDefault();

  closeFeedbackModal(dispatch);
}

const submitText = (model) => {
  if (modalState(model) === "SUBMITTING"){
    return "Submitting";
  } else {
    return "Submit";
  }
}

const title = (model) => {
  return _.get(
    model,
    ["ui", "feedbackModal", "item", "title" ],
    "Nothing"
  );
}

const modalStyle = {
  position: "fixed",
  top: "25%",
  left: "25%",
  width: "50%",
  backgroundColor: "white",
  padding: "30px",
  boxShadow: "2px 2px 8px #888",
  zIndex: "999"
};


const PostSubmitModal = ({model, dispatch}) => {
  return(
    <div style={modalStyle}>
      <div className="inner">
        <h2>Thank you!</h2>
        <p className="space no_indent">
          {
            `Thank you for providing feedback on ${title(model)}.  ` +
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
          onClick={_.partial(handleClose, dispatch)}
          style={{marginTop: "10px"}}
        >Close</a>
      </div>
    </div>
  )
};

export default FeedbackModal;