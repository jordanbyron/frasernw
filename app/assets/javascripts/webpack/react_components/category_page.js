import React from "react";
import LoadingContainer from "react_components/loading_container";
import FilterTable from "react_components/filter_table";
import FeedbackModal from "react_components/feedback_modal";

const CategoryPageContents = (props) => (
  <div style={{marginTop: "10px"}}>
    <FilterTable {...props}/>
  </div>
);

const CategoryPage = (props) => (
  <div>
    <LoadingContainer
      isLoading={props.isLoading}
      renderContents={CategoryPageContents.bind(null, props)}
    />
    <FeedbackModal
      dispatch={props.dispatch}
      {...props.feedbackModal}
    />
  </div>
);

export default CategoryPage;
