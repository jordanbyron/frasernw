var keys = require("lodash/object/keys");
var every = require("lodash/collection/every");
var pick = require("lodash/object/pick");
var values = require("lodash/object/values");


var filterByCities = function(record, cityFilters) {
  return record.cityIds.some((id) => cityFilters[id]);
}

var filterByProcedureSpecializations = function(record, psFilters) {
  if (every((values(psFilters)), (value) => !value)) {
    return true;
  } else {
    return record.procedureSpecializationIds.some((id) => psFilters[id]);
  }
}

var filterByReferrals = function(record, referralsFilters) {
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

  return every(tests, (test) => test(record, referralsFilters));
}

var filterBySex = function(record, sexFilters) {
  return (every((values(sexFilters)), (value) => !value)) ||
    (every((values(sexFilters)), (value) => value)) ||
    sexFilters[record.sex];
}

var filterBySchedule = function(record, scheduleFilters) {
  if (every((values(scheduleFilters)), (value) => !value)) {
    return true;
  }

  var activatedDays = pick(scheduleFilters, (val) => val)
  var activatedDayIds = keys(activatedDays)

  return every(activatedDayIds, (id) => {
    return (record.scheduledDayIds.indexOf(id) > -1);
  });
}

var referentFilterPredicates = [
  {key: "city", fn: filterByCities},
  {key: "procedureSpecializations", fn: filterByProcedureSpecializations},
  {key: "referrals", fn: filterByReferrals},
  {key: "schedule", fn: filterBySchedule}
]

var specialistFilterPredicates = referentFilterPredicates.concat([
  {key: "sex", fn: filterBySex}
]);

var clinicFilterPredicates = referentFilterPredicates;

module.exports = {
  specialists: function(record, filters) {
    return every(specialistFilterPredicates, (predicate) => {
      return predicate.fn(record, filters[predicate.key]);
    });
  },
  clinics: function(record, filters) {
    return every(clinicFilterPredicates, (predicate) => {
      return predicate.fn(record, filters[predicate.key]);
    });
  }
}
