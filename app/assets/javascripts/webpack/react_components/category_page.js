import React from "react";
import LoadingContainer from "react_components/loading_container";
import FilterTable from "react_components/filter_table";

const CategoryPageContents = (props) => (
  <FilterTable {...props}/>
);

const CategoryPage = (props) => (
  <LoadingContainer
    isLoading={props.isLoading}
    renderContents={CategoryPageContents.bind(null, props)}
  />
);

export default CategoryPage;
