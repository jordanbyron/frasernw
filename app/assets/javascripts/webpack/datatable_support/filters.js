var keys = require("lodash/object/keys");
var every = require("lodash/collection/every");
var pick = require("lodash/object/pick");
var values = require("lodash/object/values");

var filterByCities = function(record, filters) {
  return record.cityIds.some((id) => filters.city[id]);
}

var filterByProcedures = function(record, filters) {
  if (every((values(filters.procedures)), (value) => !value)) {
    return true;
  } else {
    return record.procedureIds.some((id) => {
      return filters.procedures[id];
    });
  }
}

var filterByReferrals = function(record, filters) {
  var tests = [
    function(record, filters) {
      return ((filters.acceptsReferralsViaPhone == false) ||
        record.acceptsReferralsViaPhone);
    },
    function(record, filters) {
      return ((filters.patientsCanBook == false) || record.patientsCanBook);
    },
    function(record, filters) {
      return ((filters.respondsWithin == 0) ||
        (record.respondsWithin <= filters.respondsWithin));
    }
  ]

  return every(tests, (test) => test(record, filters));
}

var filterBySex = function(record, filters) {
  return (every((values(filters.sex)), (value) => !value)) ||
    (every((values(filters.sex)), (value) => value)) ||
    filters.sex[record.sex];
}


var filterByLanguages = function(record, filters) {
  return (every((values(filters.languages)), (value) => !value)) ||
    (every((values(filters.languages)), (value) => value)) ||
    record.languageIds.some((id) => filters.languages[id]);
}

var filterBySchedule = function(record, filters) {
  if (every((values(filters.schedule)), (value) => !value)) {
    return true;
  }

  var activatedDays = pick(filters.schedule, (val) => val)
  var activatedDayIds = keys(activatedDays)

  return every(activatedDayIds, (id) => {
    return (record.scheduledDayIds.indexOf(id) > -1);
  });
}

var referentFilterPredicates = [
  filterByCities,
  filterByProcedures,
  filterByReferrals,
  filterByLanguages,
  filterBySchedule
]

var specialistFilterPredicates = referentFilterPredicates.concat([
  filterBySex
]);

var clinicFilterPredicates = referentFilterPredicates;

module.exports = {
  specialists: function(record, filters) {
    return every(specialistFilterPredicates, (predicate) => {
      return predicate(record, filters);
    });
  },
  clinics: function(record, filters) {
    return every(clinicFilterPredicates, (predicate) => {
      return predicate(record, filters);
    });
  }
}
