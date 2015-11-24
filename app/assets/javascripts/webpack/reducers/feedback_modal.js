import _ from "lodash";

export default function(state, action) {
  switch(action.type){
  case "OPEN_FEEDBACK_MODAL":
    return _.assign(
      {},
      {
        state: "PRE_SUBMIT"
      },
      action.data
    );
  case "CLOSE_FEEDBACK_MODAL":
    return {
      state: "HIDDEN"
    };
  case "SUBMITTING_FEEDBACK":
    return _.assign(
      {},
      state,
      { state: "SUBMITTING" }
    );
  case "SUBMITTED_FEEDBACK":
    return _.assign(
      {},
      state,
      { state: "POST_SUBMIT" }
    );
  default:
    return state;
  }
};
