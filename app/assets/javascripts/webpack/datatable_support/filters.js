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
    }
  },
  procedures: {
    test: function(filters) {
      return some((values(filters.procedures)), (value) => value);
    },
    predicate: function(record, filters) {
      return record.procedureIds.some((id) => {
        return filters.procedures[id];
      });
    }
  },
  acceptsReferralsViaPhone: {
    test: function(filters) {
      return filters.acceptsReferralsViaPhone;
    },
    predicate: function(record, filter) {
      return record.acceptsReferralsViaPhone;
    }
  },
  patientsCanBook: {
    test: function(filters) {
      return filters.patientsCanBook;
    },
    predicate: function(record, filter) {
      return record.patientsCanBook;
    }
  },
  respondsWithin: {
    test: function(filters) {
      return filters.respondsWithin != 0;
    },
    predicate: function(record, filters) {
      return (record.respondsWithin <= filters.respondsWithin);
    }
  },
  sex: {
    test: function(filters) {
      return uniq(values(filters.sex)).length > 1;
    },
    predicate: function(record, filters) {
      return filters.sex[record.sex];
    }
  },
  languages: {
    test: function(filters) {
      return some(values(filters.langages), (value) => value);
    },
    predicate: function(record, filters) {
      return record.languageIds.some((id) => filters.languages[id]);
    }
  },
  schedule: {
    test: function(filters) {
      some(values(filters.schedule), (value) => !value)
    },
    predicate: function(record, filters) {
      var activatedDays = pick(filters.schedule, (val) => val)
      var activatedDayIds = keys(activatedDays)

      return every(activatedDayIds, (id) => {
        return (record.scheduledDayIds.indexOf(id) > -1);
      });
    }
  }
}
