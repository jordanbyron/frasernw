var uniq = require("lodash/array/uniq");
var pick = require("lodash/object/pick");
var values = require("lodash/object/values");

var verb = function(props) {
  if (props.bodyRows.length > 0){
    return "Showing all";
  } else {
    return "There are no " + props.filterFunction;
  }
}

var collection = function(props) {
  var fromRecords = uniq(
    props.bodyRows.map((row) => row.record.collectionName)
  ).join(" and ");

  if (fromRecords.length > 0) {
    return fromRecords;
  } else {
    return props.collectionName;
  }
}

var pronoun = function(props) {
  if (props.filterFunction === "clinics") {
    return "that";
  } else if (props.filterFunction === "specialists") {
    return "who";
  } else {
    return "who";
  }
}

module.exports = function(operativeFilters, props) {
  let trailingFilterPredicates = values(pick(operativeFilters, ((filter => {
    return filter.summaryPlacement === "trailing"
  }))))
    .filter((filter) => filter.test(props.filterValues))
    .map((filter) => filter.summary(props))
    .filter((segment) => segment.length > 0)
    .join(" and ");

  let leadingFilterPredicates = values(pick(operativeFilters, ((filter => {
    return filter.summaryPlacement === "leading"
  }))))
    .filter((filter) => filter.test(props.filterValues))
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
