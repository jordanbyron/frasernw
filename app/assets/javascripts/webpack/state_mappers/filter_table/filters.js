var keys = require("lodash/object/keys");
var every = require("lodash/collection/every");
var pick = require("lodash/object/pick");
var values = require("lodash/object/values");
var find = require("lodash/collection/find");
var some = require("lodash/collection/some");
var uniq = require("lodash/array/uniq");

module.exports = {
  cities: {
    isActivated: function(filters) {
      return (
        !every((values(filters.cities)), (value) => value)
      );
    },
    predicate: function(record, filters) {
      return record.cityIds.some((id) => filters.cities[id]);
    },
    summary: function() {
      return "are in your selected cities";
    },
    summaryPlacement: "trailing",
    isSummaryActivated: function(props) {
      return (!_.isEqual(
        props.referralCities.sort(),
        _.keys(_.pick(props.filterValues.cities, _.identity)).map((id) => parseInt(id)).sort()
      ) || props.bodyRows.length === 0);
    }
  },
  teleserviceRecipients: {
    isActivated: function(filters) {
      return _.some(_.values(filters.teleserviceRecipients)) &&
        !_.some(_.values(filters.teleservicetypes));
    },
    predicate: function(record, filters) {
      const performsPatient = _.some(_.values(_.pick(record.teleserviceFeeTypes, [1, 2])))
      const performsProvider = _.some(_.values(_.pick(record.teleserviceFeeTypes, [3, 4])))

      if (filters.teleserviceRecipients.patient && !performsPatient)
        return false;
      }
      else if (filters.teleserviceRecipients.provider && !performsProvider)
        return false;
      }
      else {
        return true;
      }
    },
    summary: function() {
      if (filters.teleserviceRecipients.patient && filters.teleserviceRecipients.provider) {
        return "performs telehealth patient and provider services";
      }
      else if (filters.teleserviceRecipients.patient) {
        return "performs telehealth patient services";
      }
      else if (filters.teleserviceRecipients.provider) {
        return "performs telehealth provider services";
      }
    },
    summaryPlacement: "trailing"
  },
  teleserviceFeeTypes: {
    isActivated: function(filters) {
      return _.some(_.values(filters.teleserviceFeeTypes));
    },
    predicate: function(record, filters) {
      return _.every(
        _.keys(_.pick(teleserviceFeeTypes, _.identity)),
        (feeTypeKey) => {
          return _.includes(record.teleserviceFeeTypes, feeTypeKey);
        }
      );
    },
    summary: function() {
      if (filters.teleserviceRecipients.patient && filters.teleserviceRecipients.provider) {
        return "performs telehealth patient and provider services";
      }
      else if (filters.teleserviceRecipients.patient) {
        return "performs telehealth patient services";
      }
      else if (filters.teleserviceRecipients.provider) {
        return "performs telehealth provider services";
      }
    },
    summaryPlacement: "trailing"
  },
  procedures: {
    isActivated: function(filters) {
      return some((values(filters.procedures)), (value) => value);
    },
    predicate: function(record, filters) {
      return every(_.keys(_.pick(filters.procedures, _.identity)), (id) => {
        return (_.includes(record.procedureIds, parseInt(id)) &&
          (
            filters.respondsWithin === undefined ||
            record.customLagtimes[id] === undefined ||
            record.customLagtimes[id] <= parseInt(filters.respondsWithin)
          )
        );
      });
    },
    summary: function(props) {
      return "accept referrals in " + _.keys(_.pick(props.filterValues.procedures, _.identity)).map(
        (ps) => props.app.procedures[ps].name
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  acceptsReferralsViaPhone: {
    isActivated: function(filters) {
      return filters.acceptsReferralsViaPhone;
    },
    predicate: function(record, filter) {
      return record.acceptsReferralsViaPhone;
    },
    summary: function() {
      return "accept referrals via phone";
    },
    summaryPlacement: "trailing"
  },
  patientsCanBook: {
    isActivated: function(filters) {
      return filters.patientsCanBook;
    },
    predicate: function(record, filter) {
      return record.patientsCanBook;
    },
    summary: function() {
      return "patients can call to book after referral";
    },
    summaryPlacement: "trailing"
  },
  respondsWithin: {
    isActivated: function(filters) {
      return filters.respondsWithin != 0;
    },
    predicate: function(record, filters) {
      return (record.respondsWithin !== null &&
        record.respondsWithin <= parseInt(filters.respondsWithin));
    },
    summary: function(props) {
      var respondsWithinKey = props.filterValues.respondsWithin;
      var respondsWithinLabels = props.app.respondsWithinSummaryLabels;
      return ("respond to referrals " + respondsWithinLabels[respondsWithinKey]);
    },
    summaryPlacement: "trailing"
  },
  sexes: {
    isActivated: function(filters) {
      return uniq(values(filters.sexes)).length > 1;
    },
    predicate: function(record, filters) {
      return filters.sexes[record.sex];
    },
    summary: function(props) {
      if (props.filterValues.sexes.male) {
        return "male";
      } else if (props.filterValues.sexes.female) {
        return "female";
      }
    },
    summaryPlacement: "leading"
  },
  languages: {
    isActivated: function(filters) {
      return some((values(filters.languages)), (value) => value);
    },
    predicate: function(record, filters) {
      return every(_.keys(_.pick(filters.languages, _.identity)), (id) => {
        return _.includes(record.languageIds, parseInt(id));
      });
    },
    summary: function(props) {
      if (props.panelTypeKey === "specialists"){
        var leadingPhrase = "speak ";
      } else if (props.panelTypeKey === "clinics"){
        var leadingPhrase = "have a clinician who speaks ";
      }

      return leadingPhrase + _.keys(_.pick(props.filterValues.languages, _.identity)).map(
        (language) => props.app.languages[language].name
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  scheduleDays: {
    isActivated: function(filters) {
      return some(values(filters.scheduleDays), (value) => value);
    },
    predicate: function(record, filters) {
      var activatedDays = pick(filters.scheduleDays, (val) => val)
      var activatedDayIds = keys(activatedDays)

      return every(activatedDayIds, (id) => {
        return _.includes(record.scheduledDayIds, parseInt(id));
      });
    },
    summary: function(props) {
      return "are open on " + _.keys(_.pick(props.filterValues.scheduleDays, _.identity)).map(
        (day) => props.app.dayKeys[day]
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  clinicAssociations: {
    isActivated: function(filters) {
      return filters.clinicAssociations != "0";
    },
    predicate: function(record, filters) {
      return _.includes(record.clinicIds, filters.clinicAssociations);
    },
    summary: function(props) {
      return ("are associated with " +
        props.app.clinics[props.filterValues.clinicAssociations].name);
    },
    summaryPlacement: "trailing"
  },
  hospitalAssociations: {
    isActivated: function(filters) {
      return filters.hospitalAssociations != "0";
    },
    predicate: function(record, filters) {
      return _.includes(record.hospitalIds, parseInt(filters.hospitalAssociations));
    },
    summary: function(props) {
      return ("are associated with " +
        props.app.hospitals[props.filterValues.hospitalAssociations].name);
    },
    summaryPlacement: "trailing"
  },
  public: {
    isActivated: function(filters) {
      return filters.public
    },
    predicate: function(record, filters) {
      return record.isPublic;
    },
    summary: function(props) {
      return "public";
    },
    summaryPlacement: "leading"
  },
  private: {
    isActivated: function(filters) {
      return filters.private
    },
    predicate: function(record, filters) {
      return record.isPrivate;
    },
    summary: function(props) {
      return "private";
    },
    summaryPlacement: "leading"
  },
  interpreterAvailable: {
    isActivated: function(filters) {
      return filters.interpreterAvailable
    },
    predicate: function(record, filters) {
      return record.interpreterAvailable;
    },
    summary: function() {
      return "have an interpreter available";
    },
    summaryPlacement: "trailing"
  },
  wheelchairAccessible: {
    isActivated: function(filters) {
      return filters.wheelchairAccessible
    },
    predicate: function(record, filters) {
      return record.wheelchairAccessible;
    },
    summary: function(props) {
      return "wheelchair accessible";
    },
    summaryPlacement: "leading"
  },
  careProviders: {
    isActivated: function(filters) {
      return some(values(filters.careProviders), (value) => value);
    },
    predicate: function(record, filters) {
      return every(_.keys(_.pick(filters.careProviders, _.identity)), (id) => {
        return _.includes(record.careProviderIds, parseInt(id));
      });
    },
    summary: function(props) {
      return "have a " + _.keys(_.pick(props.filterValues.careProviders, _.identity)).map(
        (id) => props.app.careProviders[id].name
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  subcategories: {
    isActivated: function(filters) {
      if(_.isObject(filters.subcategories)){
        return some(values(filters.subcategories), (value) => value);
      } else {
        return (filters.subcategories !== "0");
      }
    },
    predicate: function(record, filters) {
      if(_.isObject(filters.subcategories)){
        return _.find(_.keys(_.pick(filters.subcategories, _.identity)), (id) => {
          return record.categoryId === parseInt(id);
        });
      } else {
        return record.categoryId === parseInt(filters.subcategories);
      }
    },
    summary: function(props) {
      if(_.isObject(props.filterValues.subcategories)){
        return "are in one of the following subcategories: " + _.keys(_.pick(props.filterValues.subcategories, _.identity)).map(
          (id) => props.app.contentCategories[id].name
        ).join(", ");
      } else {
        return `are subcategorized as ${props.app.contentCategories[props.filterValues.subcategories].name}`;
      }
    },
    summaryPlacement: "trailing"
  },
  inProgress: {
    isActivated: function() {
      return true;
    },
    predicate: function(record, filters, isAdmin) {
      return (isAdmin || !record.isInProgress);
    }
  },
  status: {
    isActivated: function() {
      return true;
    },
    predicate: function(record) {
      // no blank statuses
      return record.statusClassKey !== 6;
    }
  },
  showInTable: {
    isActivated: function() {
      return true;
    },
    predicate: function(record) {
      // no blank statuses
      return record.showInTable;
    }
  },
  specializations: {
    isActivated: function(filters) {
      return (filters.specializations !== "0");
    },
    predicate: function(record, filters) {
      return _.includes(record.specializationIds, parseInt(filters.specializations));
    },
    summary: function(props) {
      return `pertain to ${props.app.specializations[props.filterValues.specializations].name}`;
    },
    summaryPlacement: "trailing"
  },
}
