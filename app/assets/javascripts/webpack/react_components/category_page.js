import React from "react";
import LoadingContainer from "react_components/loading_container";
import FilterTable from "react_components/filter_table";
import InlineArticles from "react_components/inline_articles";
import FeedbackModal from "react_components/feedback_modal";
const ContentComponents = {
  FilterTable: FilterTable,
  InlineArticles: InlineArticles
}

const CategoryPageContents = (props) => (
  <div style={{marginTop: "10px"}}>
    { React.createElement(ContentComponents[props.componentType], props.componentProps) }
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

module.exports = CategoryPage;
