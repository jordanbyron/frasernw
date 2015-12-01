var FILTER_VALUE_GENERATORS = require("./filter_value_generators");
var _ = require("lodash");
import React from "react";
import MaybeContent from "react_components/maybe_content";
import { from } from "utils";

const ProcedureLabel = (props) => {
  let { procedure, panelKey } = props;

  return(
    <span>
      <span>{procedure.name}</span>
      <MaybeContent
        shouldDisplay={procedure.customWaittime[panelKey]}
        contents={_.partial(React.createElement, 'i', { className: "icon-link", style: { marginLeft: "5px"}})}
      />
    </span>
  );
};

module.exports = {
  procedures: function(panelKey, maskingSet, state) {
    let _filterValues =
      FILTER_VALUE_GENERATORS["procedures"](state, maskingSet, panelKey);

    let _normalizedProcedures = state.app.procedures;

    let _procedureFilters = {
      specialization: function() {
        let _procedures = state.app.specializations[state.ui.specializationId].nestedProcedureIds;

        let shouldShow = (procedure, id) => (
          _.includes(_.keys(_filterValues), id) &&
            !procedure.assumed[panelKey]
        )

        let procedureFilter = (procedure, procedureId) => ({
          id: procedureId,
          name: _normalizedProcedures[parseInt(procedureId)].name,
          label: <ProcedureLabel procedure={_normalizedProcedures[parseInt(procedureId)]} panelKey={panelKey}/>,
          value: _filterValues[procedureId],
          focused: procedure.focused,
          children: processNested(procedure.children)
        })

        let processNested = (procedures) => (
          from(
            _.partialRight(_.sortBy, "name"),
            _.partialRight(_.map, procedureFilter),
            _.partialRight(_.pick, shouldShow),
            procedures
          )
        )

        return processNested(_procedures);
      },
      procedure: function() {
        let procedureFilter = (procedureId) => ({
          id: `${procedureId}`,
          name: _normalizedProcedures[parseInt(procedureId)].name,
          label: <ProcedureLabel procedure={_normalizedProcedures[parseInt(procedureId)]} panelKey={panelKey}/>,
          value: _filterValues[procedureId],
          focused: true,
          children: []
        })

        return from(
          _.partialRight(_.sortBy, "name"),
          _.partialRight(_.map, procedureFilter),
          state.app.procedures[state.ui.procedureId].childrenProcedureIds
        );
      }
    }[state.ui.pageType]()

    let title = {
      specialization: "Accepts referrals for",
      procedure: "Sub-Areas of Practice"
    }[state.ui.pageType];

    return {
      filters: {
        focusedProcedures: _procedureFilters.filter((filter) => filter.focused),
        unfocusedProcedures: _procedureFilters.filter((filter) => !filter.focused)
      },
      title: title,
      shouldDisplay: _.any(_procedureFilters),
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
        wheelchairAccessible: { value: FILTER_VALUE_GENERATORS["wheelchairAccessible"](state, maskingSet, panelKey) },
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
