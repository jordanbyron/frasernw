var uniq = require("lodash/array/uniq");
var pick = require("lodash/object/pick");
var values = require("lodash/object/values");
var filters = require("./filters");

var verb = function(props) {
  if (props.bodyRows.length > 0){
    return "Showing all";
  } else {
    return "There are no";
  }
}

var collection = function(props) {
  var fromRecords = uniq(
    props.bodyRows.map((row) => row.record.panelTypeKey)
  ).join(" and ");

  if (fromRecords.length > 0) {
    return fromRecords;
  } else {
    return (props.labelName || props.panelTypeKey);
  }
}

var pronoun = function(props) {
  if (props.panelTypeKey === "clinics") {
    return "that";
  } else if (props.panelTypeKey === "specialists") {
    return "who";
  } else {
    return "that";
  }
}

module.exports = function(props) {
  var activatedFilters = _.values(_.pick(filters, (filter, key) => {
    if(_.includes(props.availableFilters, key)){
      if (filter.isSummaryActivated) {
        return filter.isSummaryActivated(props);
      } else {
        return filter.isActivated(props.filterValues);
      }
    } else {
      return false;
    }
  }));

  var trailingFilterPredicates = activatedFilters.filter((filter) => filter.summaryPlacement === "trailing")
    .map((filter) => filter.summary(props))
    .filter((segment) => segment.length > 0)
    .join(" and ");

  var leadingFilterPredicates = activatedFilters.filter((filter) => filter.summaryPlacement === "leading")
    .map((filter) => filter.summary(props))
    .filter((segment) => segment.length > 0)
    .join(", ");

  if (leadingFilterPredicates.length === 0 &&
    trailingFilterPredicates.length === 0) {
    return "";
  } else if (trailingFilterPredicates.length === 0) {
    return ([
      verb(props),
      leadingFilterPredicates,
      collection(props)
    ]).join(" ");
  } else {
    return ([
      verb(props),
      leadingFilterPredicates,
      collection(props),
      pronoun(props),
      trailingFilterPredicates
    ]).join(" ");
  }
}
