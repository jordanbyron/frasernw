import React from "react";
import _ from "lodash";
import { buttonIsh } from "stylesets";
import { scopedByRouteAndTab } from "controller_helpers/collection_shown";
import { setPage } from "action_creators"
import { currentPage, ROWS_PER_PAGE } from "controller_helpers/pagination";
import { route } from "controller_helpers/routing";

const Pagination = ({model, dispatch}) => {
  if(route !== "/news_items" || totalPages(model) === 0) {
    return <noscript/>;
  } else {
    return (
      <div className="pagination">
        <ul>
          <PreviousArrow model={model} dispatch={dispatch}/>
          { Pages(model, dispatch) }
          <NextArrow model={model} dispatch={dispatch}/>
        </ul>
      </div>
    );
  }
};

const totalPages = (model) => {
  return _.ceil(scopedByRouteAndTab(model).length / ROWS_PER_PAGE)
}

const NextArrow = ({dispatch, model}) => {
  return(
    <Arrow
      direction={"next"}
      setPage={
        _.partial(
          setPage,
          dispatch,
          _.min([(currentPage(model) + 1), totalPages(model)]),
          model
        )
      }
    />
  );
};

const PreviousArrow = ({dispatch, model}) => {
  return(
    <Arrow
      direction={"previous"}
      setPage={
        _.partial(
          setPage,
          dispatch,
          _.max([ (currentPage(model) - 1), 1]),
          model
        )
      }
    />
  );
};

const Arrow = ({direction, setPage}) => {
  return(
    <li
      className={`${direction}_page disabled`}
      onClick={setPage}
      style={buttonIsh}
    >
      <a
        className={`#{direction}_page disabled`}
        style={buttonIsh}
      >{_.capitalize(direction)}</a>
    </li>
  );
};

const Pages = (model, dispatch) => {
  let pages = []
  for(let i = 0; i < totalPages(model); i++) {
    pages = pages.concat(
      <Page
        page={i + 1}
        model={model}
        dispatch={dispatch}
        key={i}
      />
    );
  }
  return pages;
}

const Page = ({page, model, dispatch}) => (
  <li
    style={buttonIsh}
    onClick={_.partial(setPage, dispatch, page, model)}
    className={page === currentPage(model) ? "active" : ""}
    key={page}
  >
    <a>{ page }</a>
  </li>
);

export default Pagination;
