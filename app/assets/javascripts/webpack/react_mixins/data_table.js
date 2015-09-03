var objectAssign = require("object-assign");

var labels = function(props) {
  return objectAssign(
    {},
    props.labels,
    props.globalData.labels
  );
}

var decorateWithPanelKey = function(actionCreator, panelKey) {
  return (...args) => {
    return objectAssign(
      { panelKey: panelKey },
      actionCreator(...args)
    );
  };
}

module.exports  = {
  labels: labels,
  updateFilter: function(dispatch, filterType, update){
    return dispatch({
      type: "FILTER_UPDATED",
      filterType: filterType,
      update: update
    });
  },
  handleClearFilters: function(dispatch, filterFunctionName) {
    return (e) => {
      e.preventDefault();

      return dispatch({
        type: "CLEAR_FILTERS",
        filterFunction: filterFunctionName
      });
    };
  },
  toggleFilterGroupVisibility: function(dispatch, key) {
    return ()=> {
      return dispatch({
        type: "TOGGLE_FILTER_VISIBILITY",
        filterKey: key
      });
    }
  },
  handleHeaderClick: function(dispatch, key) {
    return () => {
      return dispatch({
        type: "HEADER_CLICK",
        headerKey: key
      });
    };
  },
  toggleableFilterProps: function(props, filterGroupKey) {
    return {
      labels: labels(props),
      filterVisibility: props.filterVisibility,
      filterValues: props.filterValues,
      arrangements: props.filterArrangements,
      dispatch: props.dispatch,
      filterGroupKey: filterGroupKey
    }
  }
}
