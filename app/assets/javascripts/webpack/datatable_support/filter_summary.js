var uniq = require("lodash/array/uniq");
var keysAtTruthyVals = require("../utils").keysAtTruthyVals;

var referentTrailingFilterPredicates = [
  function(props) {
    var activatedProcedureSpecializations = keysAtTruthyVals(
      props.filterValues.procedureSpecializations
    )

    if (activatedProcedureSpecializations.length > 0){
      return "accept referrals in " + activatedProcedureSpecializations.map(
        (ps) => props.labels.procedureSpecializations[ps]
      ).join(" and ")
    } else {
      return ""
    }
  },
  function(props) {
    if (props.filterValues.acceptsReferralsViaPhone){
      return "accept referrals via phone";
    } else {
      return ""
    }
  },
  function(props) {
    var respondsWithinKey = props.filterValues.respondsWithin;
    var respondsWithinLabels = props.labels.respondsWithinSummaryLabels

    if (respondsWithinKey  == 0){
      return "";
    } else {
      return ("respond to referrals " + respondsWithinLabels[respondsWithinKey]);
    }
  },
  function(props) {
    if (props.filterValues.patientsCanBook){
      return "patients can call to book after referral";
    } else {
      return "";
    }
  },
  function(props) {
    var activatedDays = keysAtTruthyVals(
      props.filterValues.schedule
    )

    if (activatedDays.length > 0){
      return "are open on " + activatedDays.map(
        (day) => props.labels.schedule[day]
      ).join(" and ");
    } else {
      return "";
    }
  },
  function(props) {
    var activatedLanguages = keysAtTruthyVals(
      props.filterValues.languages
    )
    if (props.filterFunction === "specialists"){
      var leadingPhrase = "speak ";
    } else if (props.filterFunction === "clinics"){
      var leadingPhrase = "have a clinician who speaks ";
    }

    if (activatedLanguages.length > 0){
      return leadingPhrase + activatedLanguages.map(
        (language) => props.labels.languages[language]
      ).join(" and ");
    } else {
      return "";
    }
  }
]

var trailingFilterPredicateFunctions = {
  clinics: referentTrailingFilterPredicates,
  specialists: referentTrailingFilterPredicates
}

var leadingFilterPredicateFunctions = {
  clinics: [],
  specialists: [
    function(props) {
      if (props.filterValues.sex.male && !props.filterValues.sex.female) {
        return "male";
      } else if (props.filterValues.sex.female && !props.filterValues.sex.male) {
        return "female";
      } else {
        return "";
      }
    }
  ]
}

var verb = function(props) {
  if (props.anyResults){
    return "Showing all";
  } else {
    return "There are no";
  }
}

var getLeadingFilterPredicates = function(props) {
  return leadingFilterPredicateFunctions[props.filterFunction]
    .map((predicate) => predicate(props))
    .join(", ");
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

var getTrailingFilterPredicates = function(props) {
  return trailingFilterPredicateFunctions[props.filterFunction]
    .map((segment) => segment(props))
    .filter((segment) => segment.length > 0)
    .join(" and ");
}

module.exports = function(props) {
  let leadingFilterPredicates = getLeadingFilterPredicates(props);
  let trailingFilterPredicates = getTrailingFilterPredicates(props);

  if (leadingFilterPredicates.length == 0 &&
    trailingFilterPredicates.length == 0) {
    return "";
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
