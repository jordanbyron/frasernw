import * as utils from "utils";
import _ from "lodash";
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import { matchedRoute } from "controller_helpers/routing";
import * as filterValues from "controller_helpers/filter_values";

const sidebarFilters = {
  cities: {
    isActivated: function(model) {
      return activatedFilterSubkeys.cities(model).length !==
        _.values(model.app.cities).length;
    },
    predicate: function(record, model) {

      return _.intersection(activatedFilterSubkeys.cities(model), record.cityIds).
        pwPipe(_.some)
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
    isActivated: function(model) {
      return activatedFilterSubkeys.teleserviceRecipients(model).pwPipe(_.some) &&
        !activatedFilterSubkeys.teleserviceFeeTypes(model).pwPipe(_.some);
    },
    predicate: function(record, model) {
      const recordPerformsPatient = _.some(
        record.teleserviceFeeTypes,
        (type) => _.includes([1, 2], type)
      )
      const recordPerformsProvider = _.some(
        record.teleserviceFeeTypes,
        (type) => _.includes([3, 4], type)
      )

      if (filterValues.teleserviceRecipients(model, "patient") &&
        !recordPerformsPatient) {

        return false;
      }
      else if (filterValues.teleserviceRecipients(model, "provider") &&
        !recordPerformsProvider) {

        return false;
      }
      else {
        return true;
      }
    },
    summary: function(props) {
      if (props.filterValues.teleserviceRecipients.patient && props.filterValues.teleserviceRecipients.provider) {
        return "provide telehealth services to patients and other providers";
      }
      else if (props.filterValues.teleserviceRecipients.patient) {
        return "provide telehealth services to patients";
      }
      else if (props.filterValues.teleserviceRecipients.provider) {
        return "provide telehealth services to other providers";
      }
    },
    summaryPlacement: "trailing"
  },
  teleserviceFeeTypes: {
    isActivated: function(model) {
      return activatedFilterSubkeys.teleserviceFeeTypes(model).pwPipe(_.some);
    },
    predicate: function(record, model) {
      return utils.isSubset(
        activatedFilterSubkeys.teleserviceFeeTypes(model),
        record.teleserviceFeeTypes
      );
    },
    summary: function(props) {
      const labels = {
        1: "perform initial consultations with patients",
        2: "perform follow-ups with patients",
        3: "provide advice to healthcare providers",
        4: "participate in case conferences with other health care providers"
      }

      const activatedFeeTypes = _.keys(_.pick(
        props.filterValues.teleserviceFeeTypes,
        _.identity
      )).map((type) => labels[type]);

      const activatedList = utils.toSentence(activatedFeeTypes);

      if (activatedFeeTypes.length === 1) {
        return `${activatedList} as a telehealth service`;
      } else {
        return `${activatedList} as telehealth services`;
      }
    },
    summaryPlacement: "trailing"
  },
  procedures: {
    isActivated: function(model) {
      return activatedFilterSubkeys.procedures(model).pwPipe(_.some)
    },
    predicate: function(record, model) {
      return _.every(
        activatedFilterSubkeys.procedures(model),
        (procedureId) => {
          return (_.includes(record.procedureIds, parseInt(procedureId)) &&
            (
              filterValues.respondsWithin(model) === 0 ||
              record.customLagtimes[procedureId] === undefined ||
              record.customLagtimes[procedureId] <= parseInt(filterValues.respondsWithin)
            )
          );
        }
      )
    },
    summary: function(props) {
      return "accept referrals in " + _.keys(_.pick(props.filterValues.procedures, _.identity)).map(
        (ps) => props.app.procedures[ps].name
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  acceptsReferralsViaPhone: {
    isActivated: function(model) {
      return filterValues.acceptsReferralsViaPhone(model);
    },
    predicate: function(record, model) {
      return record.acceptsReferralsViaPhone;
    },
    summary: function() {
      return "accept referrals via phone";
    },
    summaryPlacement: "trailing"
  },
  patientsCanCall: {
    isActivated: function(model) {
      return filterValues.patientsCanCall(model);
    },
    predicate: function(record, model) {
      return record.patientsCanCall;
    },
    summary: function() {
      return "patients can call to book after referral";
    },
    summaryPlacement: "trailing"
  },
  respondsWithin: {
    isActivated: function(model) {
      return parseInt(filterValues.respondsWithin(model)) !== 0;
    },
    predicate: function(record, model) {
      return (record.respondsWithin !== null &&
        record.respondsWithin <= parseInt(filterValues.respondsWithin(model)));
    },
    summary: function(props) {
      var respondsWithinKey = props.filterValues.respondsWithin;
      var respondsWithinLabels = props.app.respondsWithinSummaryLabels;
      return ("respond to referrals " + respondsWithinLabels[respondsWithinKey]);
    },
    summaryPlacement: "trailing"
  },
  sex: {
    isActivated: function(model) {
      return activatedFilterSubkeys.sex(model).length === 1;
    },
    predicate: function(record, model) {
      return filterValues.sex(model, record.sex);
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
    isActivated: function(model) {
      return activatedFilterSubkeys.languages(model).pwPipe(_.some)
    },
    predicate: function(record, model) {
      return utils.isSubset(
        activatedFilterSubkeys.languages(model),
        record.languageIds
      );
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
    isActivated: function(model) {
      return activatedFilterSubkeys.scheduleDays(model).pwPipe(_.some);
    },
    predicate: function(record, model) {
      return utils.isSubset(
        activatedFilterSubkeys.scheduleDays(model),
        record.scheduledDayIds
      );
    },
    summary: function(props) {
      return "are open on " + _.keys(_.pick(props.filterValues.scheduleDays, _.identity)).map(
        (day) => props.app.dayKeys[day]
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  clinicAssociations: {
    isActivated: function(model) {
      return parseInt(filterValues.clinicAssociations(model)) !== 0;
    },
    predicate: function(record, model) {
      return _.includes(
        record.clinicIds,
        parseInt(filterValues.clinicAssociations(model))
      );
    },
    summary: function(props) {
      return ("are associated with " +
        props.app.clinics[props.filterValues.clinicAssociations].name);
    },
    summaryPlacement: "trailing"
  },
  hospitalAssociations: {
    isActivated: function(model) {
      return parseInt(filterValues.hospitalAssociations(model)) !== 0;
    },
    predicate: function(record, model) {
      return _.includes(
        record.hospitalIds,
        parseInt(filterValues.hospitalAssociations(model))
      );
    },
    summary: function(props) {
      return ("are associated with " +
        props.app.hospitals[props.filterValues.hospitalAssociations].name);
    },
    summaryPlacement: "trailing"
  },
  isPublic: {
    isActivated: function(model) {
      return filterValues.isPublic(model);
    },
    predicate: function(record, model) {
      return record.isPublic;
    },
    summary: function(props) {
      return "public";
    },
    summaryPlacement: "leading"
  },
  isPrivate: {
    isActivated: function(model) {
      return filterValues.isPrivate(model);
    },
    predicate: function(record, model) {
      return record.isPrivate;
    },
    summary: function(props) {
      return "private";
    },
    summaryPlacement: "leading"
  },
  interpreterAvailable: {
    isActivated: function(model) {
      return filterValues.interpreterAvailable(model);
    },
    predicate: function(record, model) {
      return record.interpreterAvailable;
    },
    summary: function() {
      return "have an interpreter available";
    },
    summaryPlacement: "trailing"
  },
  isWheelchairAccessible: {
    isActivated: function(model) {
      return filterValues.isWheelchairAccessible(model);
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
    isActivated: function(model) {
      return activatedFilterSubkeys.careProviders(model).pwPipe(_.some);
    },
    predicate: function(record, model) {
      return utils.isSubset(
        activatedFilterSubkeys.careProviders(model),
        record.careProviderIds
      );
    },
    summary: function(props) {
      return "have a " + _.keys(_.pick(props.filterValues.careProviders, _.identity)).map(
        (id) => props.app.careProviders[id].name
      ).join(" and ");
    },
    summaryPlacement: "trailing"
  },
  subcategories: {
    isActivated: function(model) {
      if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))){
        return activatedFilterSubkeys.subcategories(model).pwPipe(_.some);
      } else {
        return parseInt(filterValues.subcategories(model)) !== 0;
      }
    },
    predicate: function(record, model) {
      if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))){
        return _.includes(
          activatedFilterSubkeys.subcategories(model),
          record.categoryId
        )
      } else {
        return record.categoryId === parseInt(filterValues.subcategories(model));
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
  specializations: {
    isActivated: function(model) {
      return (parseInt(filterValues.specializations(model)) !== 0);
    },
    predicate: function(record, model) {
      return _.includes(
        record.specializationIds,
        parseInt(filterValues.specializations(model))
      );
    },
    summary: function(props) {
      return `pertain to ${props.app.specializations[props.filterValues.specializations].name}`;
    },
    summaryPlacement: "trailing"
  }
}

export default sidebarFilters;
