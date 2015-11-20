import React from "react";
import _ from "lodash";
import { noSelect } from "stylesets";

const Relative = (direction, setPage) => {
  return(
    <li
      className={`${direction}_page disabled`}
      onClick={setPage}
      style={noSelect}
    >
      <a className={`#{direction}_page disabled ajax`}>{_.capitalize(direction)}</a>
    </li>
  );
};

const NextArrow = (setPage, currentPage, totalPages) => {
  let pageToSet = _.min([(currentPage + 1), totalPages]);
  return Relative("next", _.partial(setPage,  pageToSet));
};

const PreviousArrow = (setPage, currentPage) => {
  let pageToSet = _.max([ (currentPage - 1), 1]);
  return Relative("previous", _.partial(setPage, pageToSet));
}

const Page = (page, setPage, currentPage) => (
  <li
    style={noSelect}
    onClick={_.partial(setPage, page)}
    className={page === currentPage ? "active" : ""}
    key={page}
  >
    <a>{ page }</a>
  </li>
)

const Pages = (totalPages, setPage, currentPage) => {
  let pages = []
  for(let i = 0; i < totalPages; i++) {
    pages = pages.concat(Page((i + 1), setPage, currentPage))
  }
  return pages;
}

const Pagination = (props) => {
  return (
    <div className="pagination">
      <ul>
        { PreviousArrow(props.setPage, props.currentPage) }
        { Pages(props.totalPages, props.setPage, props.currentPage) }
        { NextArrow(props.setPage, props.currentPage, props.totalPages) }
      </ul>
    </div>
  );
};

export default Pagination;
