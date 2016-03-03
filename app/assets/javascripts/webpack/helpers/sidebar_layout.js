import React from "react";

export function SidebarLayout({children}) {
  return (
    <div className="content">
      <div className="row">
        { children }
      </div>
    </div>
  );
};

const classTogglingReducedVisibility = (sectionShowingWhenReduced, thisSection) => {
  if (sectionShowingWhenReduced === thisSection){
    return "";
  } else {
    return "hide-when-reduced";
  }
}

export function SidebarLayoutMainPanel({children, sectionShowingWhenReduced}) {
  const className = [
    "span8half",
    classTogglingReducedVisibility("main", sectionShowingWhenReduced)
  ].join(" ")

  return (
    <div className={className}>
      { children }
    </div>
  );
};

export function SidebarLayoutSidePanel({children, sectionShowingWhenReduced}) {
  const className = [
    "span3",
    "offsethalf",
    "datatable-sidebar",
    classTogglingReducedVisibility("sidebar", sectionShowingWhenReduced)
  ].join(" ")

  return(
    <div className={className}>
      { children }
    </div>
  );
};
