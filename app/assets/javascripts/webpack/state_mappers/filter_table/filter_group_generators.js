var FILTER_VALUE_GENERATORS = require("./filter_value_generators");
var _ = require("lodash");

module.exports = {
  procedures: function(panelKey, maskingSet, state) {
    var generateProcedureFilters = function(nestedProcedures, maskedProcedureIds, normalizedProcedures, state) {
      var filterValues = FILTER_VALUE_GENERATORS["procedures"](state, maskingSet, panelKey);

      return _.chain(nestedProcedures)
        .pick((procedure, procedureId) => _.includes(_.keys(filterValues), procedureId) && !procedure.assumed[panelKey])
        .map((procedure, procedureId) => {
          return {
            id: procedureId,
            label: normalizedProcedures[parseInt(procedureId)].name,
            value: filterValues[procedureId],
            focused: procedure.focused,
            children: generateProcedureFilters(procedure.children, maskedProcedureIds, normalizedProcedures, state)
          };
        })
        .sortBy("label")
        .value()
    };

    var procedureFilters = generateProcedureFilters(
      state.app.specializations[state.ui.specializationId].nestedProcedureIds,
      _.flatten(maskingSet.map((record) => record.procedureIds)),
      state.app.procedures,
      state
    )

    return {
      filters: {
        focusedProcedures: procedureFilters.filter((filter) => filter.focused),
        unfocusedProcedures: procedureFilters.filter((filter) => !filter.focused)
      },
      title: "Accepts referrals for",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "procedures"], true),
      isExpanded: _.get(state, ["ui", "panels", panelKey, "filterExpansion", "procedures"], false),
      componentKey: "procedures"
    }
  },
  referrals: function(panelKey, maskingSet, state) {
    return {
      filters: {
        acceptsReferralsViaPhone: {
          label: "Accepted via phone",
          value:  FILTER_VALUE_GENERATORS["acceptsReferralsViaPhone"](state, maskingSet, panelKey)
        },
        patientsCanBook: {
          label: "Patients can call to book after referral",
          value: FILTER_VALUE_GENERATORS["patientsCanBook"](state, maskingSet, panelKey)
        },
        respondsWithin: {
          label: "Responded to within",
          value: FILTER_VALUE_GENERATORS["respondsWithin"](state, maskingSet, panelKey),
          options: _.map(state.app.respondsWithinOptions, (label, key) => {
            return {
              key: parseInt(key),
              label: label
            };
          })
        }
      },
      title: "Referrals",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "referrals"], false),
      componentKey: "referrals"
    };
  },
  sexes: function(panelKey, maskingSet, state) {
    return {
      filters: {
        sexes: {
          male: {
            value:  FILTER_VALUE_GENERATORS["sexes"](state, maskingSet, panelKey).male
          },
          female: {
            value: FILTER_VALUE_GENERATORS["sexes"](state, maskingSet, panelKey).female
          }
        },
      },
      title: "Sex",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "sexes"], false),
      componentKey: "sexes"
    };
  },
  scheduleDays: function(panelKey, maskingSet, state) {
    return {
      filters: {
        scheduleDays: _.map(
          FILTER_VALUE_GENERATORS["scheduleDays"](state, maskingSet, panelKey),
          (value, dayId) => {
            return {
              filterId: dayId,
              value: value,
              label: state.app.dayKeys[dayId]
            };
          }
        )
      },
      title: "Schedule",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "scheduleDays"], false),
      componentKey: "scheduleDays"
    };
  },
  languages: function(panelKey: string, maskingSet: Array, state: Object): Object {
    return {
      filters: {
        interpreterAvailable: {
          value: FILTER_VALUE_GENERATORS["interpreterAvailable"](state, maskingSet, panelKey)
        },
        languages: _.map(
          FILTER_VALUE_GENERATORS["languages"](state, maskingSet, panelKey),
          function(value: boolean, languageId: string) {
            return {
              filterId: languageId,
              label: state.app.languages[languageId].name,
              value: value
            };
          }
        )
      },
      title: "Languages",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "languages"], false),
      componentKey: "languages"
    }
  },
  associations: function(panelKey: string, maskingSet: Array, state: Object): Object {
    return {
      filters: {
        clinicAssociations: {
          value: FILTER_VALUE_GENERATORS["clinicAssociations"](state, maskingSet, panelKey),
          options: _.chain(maskingSet.map((record) => record.clinicIds))
            .flatten()
            .uniq()
            .map((clinicId) => {
              return {
                key: clinicId,
                label: state.app.clinics[clinicId].name
              }
            }).sortBy("label")
            .unshift({key: 0, label: "Any"})
            .value()
        },
        hospitalAssociations: {
          value: FILTER_VALUE_GENERATORS["hospitalAssociations"](state, maskingSet, panelKey),
          options: _.chain(maskingSet.map((record) => record.hospitalIds))
            .flatten()
            .uniq()
            .map((hospitalId) => {
              return {
                key: hospitalId,
                label: state.app.hospitals[hospitalId].name
              }
            }).sortBy("label")
            .unshift({key: 0, label: "Any"})
            .value()
        }
      },
      title: "Associations",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "associations"], false),
      componentKey: "associations"
    }
  },
  cities: function(panelKey: string, maskingSet: Array, state: Object): Object {
    return {
      filters: {
        cities: _.sortBy(_.map(
          FILTER_VALUE_GENERATORS["cities"](state, maskingSet, panelKey),
          function(value: boolean, cityId: string) {
            return {
              filterId: cityId,
              label: state.app.cities[cityId].name,
              value: value
            };
          }
        ), (filter) => filter.label),
        searchAllCities: {
          value: _.get(state, ["ui", "panels", panelKey, "filterValues", "searchAllCities"])
        }
      },
      title: "Cities",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "cities"], false),
      componentKey: "cities"
    };
  },
  clinicDetails: function(panelKey: string, maskingSet: Array, state: Object): Object {
    return {
      filters: {
        public: { value: FILTER_VALUE_GENERATORS["public"](state, maskingSet, panelKey) },
        private: { value: FILTER_VALUE_GENERATORS["private"](state, maskingSet, panelKey) },
        wheelchairAccessible: { value: FILTER_VALUE_GENERATORS["wheelchairAccessible"](state, maskingSet, panelKey) }
      },
      title: "Clinic Details",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "clinicDetails"], false),
      componentKey: "clinicDetails"
    };
  },
  careProviders: function(panelKey: string, maskingSet: Array, state: Object): Object {
    return {
      filters: {
        careProviders: _.map(
          FILTER_VALUE_GENERATORS["careProviders"](state, maskingSet, panelKey),
          function(value: boolean, careProviderId: string) {
            return {
              filterId: careProviderId,
              label: state.app.careProviders[careProviderId].name,
              value: value
            };
          }
        ),
      },
      title: "Care Providers",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "careProviders"], false),
      componentKey: "careProviders"
    };
  },
  subcategories: function(panelKey: string, maskingSet: Array, state: Object): Object {
    return {
      filters: {
        subcategories: _.map(
          FILTER_VALUE_GENERATORS["subcategories"](state, maskingSet, panelKey),
          function(value: boolean, subcategoryId: string) {
            return {
              filterId: subcategoryId,
              label: state.app.contentCategories[subcategoryId].name,
              value: value
            };
          }
        ),
      },
      title: "Subcategories",
      isOpen: _.get(state, ["ui", "panels", panelKey, "filterGroupVisibility", "subcategories"], true),
      componentKey: "subcategories"
    };
  }
}
