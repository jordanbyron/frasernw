import React from "react";
import { buttonIsh } from "stylesets";

export function SidebarLayout({children}) {
  return (
    <div className="content">
      <div className="row">
        { children }
      </div>
    </div>
  );
};

const classTogglingReducedVisibility = (reducedView, thisSection) => {
  if (reducedView === thisSection){
    return "";
  } else {
    return "hide-when-reduced";
  }
}

export function SidebarLayoutMainSection({children, reducedView}) {
  const className = [
    "span8half",
    classTogglingReducedVisibility("main", reducedView)
  ].join(" ")

  return (
    <div className={className}>
      { children }
    </div>
  );
};

export function SidebarLayoutSideSection({children, reducedView}) {
  const className = [
    "span3",
    "offsethalf",
    "datatable-sidebar",
    classTogglingReducedVisibility("sidebar", reducedView)
  ].join(" ")

  return(
    <div className={className}>
      { children }
    </div>
  );
};

export function SidebarLayoutReducedViewSelector({onClick, text}){
  return(
    <div className="toggle-filters visible-phone">
      <a onClick={onClick} style={buttonIsh}>
        <i className="icon-blue icon-cog icon-small"></i>
        <span style={{marginLeft: "3px"}}>{ text }</span>
      </a>
    </div>
  );
}
