var keys = require("lodash/object/keys");
var every = require("lodash/collection/every");
var pick = require("lodash/object/pick");
var values = require("lodash/object/values");
var find = require("lodash/collection/find");
var some = require("lodash/collection/some");
var uniq = require("lodash/array/uniq");
var keysAtTruthyVals = require("../utils").keysAtTruthyVals;

module.exports = {
  cities: {
    test: function(){ return true; },
    predicate: function(record, filters) {
      return record.cityIds.some((id) => filters.city[id]);
    },
    summary: function() {return "";},
    summaryPlacement: "none"
  },
  procedures: {
    test: function(filters) {
      return some((values(filters.procedures)), (value) => value);
    },
    predicate: function(record, filters) {
      return record.procedureIds.some((id) => {
        return filters.procedures[id];
      });
    },
    summary: function(props) {
      var activatedProcedures = keysAtTruthyVals(
        props.filterValues.procedures
      )

      if (activatedProcedures.length > 0){
        return "accept referrals in " + activatedProcedures.map(
          (ps) => props.labels.procedures[ps]
        ).join(" and ")
      } else {
        return ""
      }
    },
    summaryPlacement: "trailing",
  },
  acceptsReferralsViaPhone: {
    test: function(filters) {
      return filters.acceptsReferralsViaPhone;
    },
    predicate: function(record, filter) {
      return record.acceptsReferralsViaPhone;
    },
    summary: function(props) {
      if (props.filterValues.acceptsReferralsViaPhone){
        return "accept referrals via phone";
      } else {
        return ""
      }
    },
    summaryPlacement: "trailing"
  },
  patientsCanBook: {
    test: function(filters) {
      return filters.patientsCanBook;
    },
    predicate: function(record, filter) {
      return record.patientsCanBook;
    },
    summary: function(props) {
      if (props.filterValues.patientsCanBook){
        return "patients can call to book after referral";
      } else {
        return "";
      }
    },
    summaryPlacement: "trailing"
  },
  respondsWithin: {
    test: function(filters) {
      return filters.respondsWithin != 0;
    },
    predicate: function(record, filters) {
      return (record.respondsWithin <= filters.respondsWithin);
    },
    summary: function(props) {
      var respondsWithinKey = props.filterValues.respondsWithin;
      var respondsWithinLabels = props.labels.respondsWithinSummaryLabels

      if (respondsWithinKey  == 0){
        return "";
      } else {
        return ("respond to referrals " + respondsWithinLabels[respondsWithinKey]);
      }
    },
    summaryPlacement: "trailing"
  },
  sex: {
    test: function(filters) {
      return uniq(values(filters.sex)).length > 1;
    },
    predicate: function(record, filters) {
      return filters.sex[record.sex];
    },
    summary: function(props) {
      if (props.filterValues.sex.male && !props.filterValues.sex.female) {
        return "male";
      } else if (props.filterValues.sex.female && !props.filterValues.sex.male) {
        return "female";
      } else {
        return "";
      }
    },
    summaryPlacement: "leading"
  },
  languages: {
    test: function(filters) {
      return some((values(filters.languages)), (value) => value);
    },
    predicate: function(record, filters) {
      return record.languageIds.some((id) => filters.languages[id]);
    },
    summary: function(props) {
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
    },
    summaryPlacement: "trailing"
  },
  schedule: {
    test: function(filters) {
      return some(values(filters.schedule), (value) => value);
    },
    predicate: function(record, filters) {
      var activatedDays = pick(filters.schedule, (val) => val)
      var activatedDayIds = keys(activatedDays)

      return every(activatedDayIds, (id) => {
        return (record.scheduledDayIds.indexOf(id) > -1);
      });
    },
    summary: function(props) {
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
    summaryPlacement: "trailing"
  },
  clinicAssociation: {
    test: function(filters) {
      return filters.clinicAssociation != 0;
    },
    predicate: function(record, filters) {
      return find(record.clinicIds, (id) => id === filters.clinicAssociation);
    },
    summary: function(props) {
      return ("are associated with " +
        props.labels.clinics[props.filterValues.clinicAssociation]);
    },
    summaryPlacement: "trailing"
  },
  hospitalAssociation: {
    test: function(filters) {
      return filters.hospitalAssociation != 0;
    },
    predicate: function(record, filters) {
      return find(record.hospitalIds, (id) => id === filters.hospitalAssociation);
    },
    summary: function(props) {
      return ("are associated with " +
        props.labels.hospitals[props.filterValues.hospitalAssociation]);
    },
    summaryPlacement: "trailing"
  }
}
