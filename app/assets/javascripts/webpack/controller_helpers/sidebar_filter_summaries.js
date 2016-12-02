import referralCityIds from "controller_helpers/referral_city_ids"
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import * as filterValues from "controller_helpers/filter_values";
import { collectionShownName } from "controller_helpers/collection_shown";
import { route } from "controller_helpers/routing";
import recordsToDisplay from "controller_helpers/records_to_display";
import _ from "lodash"
import * as utils from "utils";

const sidebarFilterSummaries = {
  cities: {
    label: function() {
      return "are in your selected cities";
    },
    isActivated: function(model) {
      return (
        !_.isEqual(referralCityIds(model).sort(), activatedFilterSubkeys.cities(model).sort()) ||
          recordsToDisplay(model).length === 0
      );
    },
    placement: "trailing"
  },
  teleserviceRecipients: {
    label: function(model) {
      if (filterValues.teleserviceRecipients(model, "patient") &&
        filterValues.teleserviceRecipients(model, "provider")) {

        return "provide telehealth services to patients and other providers";
      }
      else if (filterValues.teleserviceRecipients(model, "patient")) {
        return "provide telehealth services to patients";
      }
      else if (filterValues.teleserviceRecipients(model, "provider")) {
        return "provide telehealth services to other providers";
      }
    },
    placement: "trailing"
  },
  teleserviceFeeTypes: {
    label: function(model) {
      const activatedList = activatedFilterSubkeys.teleserviceFeeTypes(model).
        map((type) => model.app.teleserviceFeeTypes[type])

      if (activatedList.length === 1) {
        return `provide ${activatedList.pwPipe(utils.toSentence)} as a telehealth service`;
      } else {
        return `provide ${activatedList.pwPipe(utils.toSentence)} as telehealth services`;
      }
    },
    placement: "trailing"
  },
  procedures: {
    label: function(model) {
      return "accept referrals in " +
        (activatedFilterSubkeys.procedures(model).
          map((id) => model.app.procedures[id].name).
          pwPipe(utils.toSentence));
    },
    placement: "trailing"
  },
  acceptsReferralsViaPhone: {
    label: function() {
      return "accept referrals via phone";
    },
    placement: "trailing"
  },
  patientsCanCall: {
    label: function() {
      return "patients can call to book after referral";
    },
    placement: "trailing"
  },
  bookingWaitTime: {
    label: function(model) {

      return ("respond to referrals " +
        bookingWaitTimeSummaryLabels(model)[filterValues.bookingWaitTime(model)]);
    },
    placement: "trailing"
  },
  sex: {
    label: function(model) {
      if (filterValues.sex(model, "male")) {
        return "male";
      }
      else if (filterValues.sex(model, "female")) {
        return "female";
      }
    },
    placement: "leading"
  },
  languages: {
    label: function(model) {
      if (collectionShownName(model) === "specialists"){
        var leadingPhrase = "speak";
      }
      else if (collectionShownName(model) === "clinics") {
        var leadingPhrase = "have a clinician who speaks ";
      }

      return leadingPhrase + activatedFilterSubkeys.
        languages(model).
        map((language) => model.app.languages[language].name).
        pwPipe(utils.toSentence)
    },
    placement: "trailing"
  },
  scheduleDays: {
    label: function(model) {
      return "are open on " + activatedFilterSubkeys.
        scheduleDays(model).
        map((day) => model.app.dayKeys[day]).
        pwPipe(utils.toSentence)
    },
    placement: "trailing"
  },
  clinicAssociations: {
    label: function(model) {
      return ("are associated with " +
        model.app.clinics[filterValues.clinicAssociations(model)].name);
    },
    placement: "trailing"
  },
  hospitalAssociations: {
    label: function(model) {
      return ("are associated with " +
        model.app.hospitals[filterValues.hospitalAssociations(model)].name);
    },
    placement: "trailing"
  },
  isPublic: {
    label: function(model) {
      return "public";
    },
    placement: "leading"
  },
  isPrivate: {
    label: function(model) {
      return "private";
    },
    placement: "leading"
  },
  interpreterAvailable: {
    label: function() {
      return "have an interpreter available";
    },
    placement: "trailing"
  },
  isWheelchairAccessible: {
    label: function(model) {
      return "wheelchair accessible";
    },
    placement: "leading"
  },
  careProviders: {
    label: function(model) {
      return "have a " + activatedFilterSubkeys.
        careProviders(model).
        map((id) => model.app.careProviders[id].name).
        pwPipe(utils.toSentence);
    },
    placement: "trailing"
  },
  subcategories: {
    label: function(model) {
      if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], route)){
        return "are in one of the following subcategories: " +
          activatedFilterSubkeys.
          subcategories(model).
          map((id) => model.app.contentCategories[id].name).
          pwPipe(utils.toSentence)
      }
      else {
        return "are subcategorized as " +
          model.app.contentCategories[filterValues.subcategories(model)].name;
      }
    },
    placement: "trailing"
  },
  specializations: {
    label: function(model) {
      if(_.includes(["specialists", "clinics"], collectionShownName(model))){
        return "specialize in " +
          model.app.specializations[filterValues.specializations(model)].name;
      }
      else {
        return "pertain to " +
          model.app.specializations[filterValues.specializations(model)].name;
      }
    },
    placement: "trailing"
  }
}

const bookingWaitTimeSummaryLabels = (model) => {
  return model.
    app.
    bookingWaitTimes.
    pwPipe((bookingWaitTimes) => {
      return _.reduce(
        bookingWaitTime,
        (accumulator, value, key) => {
          if (key === "1"){
            var label = "by phone when office calls for appointment";
          }
          else if (key === "2"){
            var label = "within one week"
          }
          else {
            var label = `within ${value}`
          }

          return _.assign({[key]: value}, accumulator);
        }, {})
      })
}

export default sidebarFilterSummaries;
