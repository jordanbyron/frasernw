var _ = require("lodash");
var utils = require("utils");
var referralCities = require("./referral_cities");

module.exports = {
  procedures: function(state, maskingSet, panelKey) {
    var assignValue = function(procedureId) {
      return [
        procedureId,
        _.get(state, ["ui", "panels", panelKey, "filterValues", "procedures", parseInt(procedureId)], false)
      ];
    };
    var assignedValues = function(ids) {
      return _.zipObject(ids.map(assignValue));
    };

    return {
      specialization: function(state, maskingSet, panelKey) {
        return utils.from(
          assignedValues,
          _.uniq,
          _.flatten,
          _.partialRight(_.map, (record) => record.procedureIds),
          maskingSet
        );
      },
      procedure: function(state, maskingset, panelKey) {
        return utils.from(
          assignedValues,
          state.app.procedures[state.ui.procedureId].childrenProcedureIds
        );
      }
    }[state.ui.pageType](state, maskingSet, panelKey);
  },
  acceptsReferralsViaPhone: function(state, maskingSet, panelKey) {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "acceptsReferralsViaPhone"], false);
  },
  patientsCanBook: function(state, maskingSet, panelKey) {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "patientsCanBook"], false);
  },
  respondsWithin: function(state, maskingSet, panelKey) {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "respondsWithin"], 0);
  },
  sexes: function(state, maskingSet, panelKey) {
    return {
      male: _.get(state, ["ui", "panels", panelKey, "filterValues", "sexes", "male"], false),
      female: _.get(state, ["ui", "panels", panelKey, "filterValues", "sexes", "female"], false)
    }
  },
  scheduleDays: function(state, maskingSet, panelKey) {
    return({
      specialists: [6, 7],
      clinics: [1, 2, 3, 4, 5, 6, 7]
    }[panelKey].reduce((memo, day) => {
      return _.assign(
        { [day]: _.get(state, ["ui", "panels", panelKey, "filterValues", "scheduleDays", day], false) },
        memo
      );
    }, {}));
  },
  interpreterAvailable: function(state: Object, maskingSet: Array, panelKey: string): boolean {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "interpreterAvailable"], false);
  },
  languages: function(state: Object, maskingSet: Array, panelKey: string): Object {
    return _.chain(maskingSet)
      .map((record) => record.languageIds)
      .flatten()
      .uniq()
      .reduce((memo, id) => {
        return _.assign(
          { [id]: _.get(state, ["ui", "panels", panelKey, "filterValues", "languages", id], false) },
          memo
        );
      }, {})
      .value()
  },
  clinicAssociations: function(state: Object, maskingSet: Array, panelKey: string): number {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "clinicAssociations"], 0)
  },
  hospitalAssociations: function(state: Object, maskingSet: Array, panelKey: string): number {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "hospitalAssociations"], 0)
  },
  cities: function(state: Object, maskingSet: Array, panelKey: string): Object {
    return _.reduce(
      _.values(state.app.cities),
      function(memo: Object, city: Object): Object {
        var value = _.get(
          state,
          ["ui", "panels", panelKey, "filterValues", "cities", city.id ],
          _.includes(referralCities(state), parseInt(city.id))
        );

        return _.assign(
          { [city.id] : value },
          memo
        );
      },
      {}
    );
  },
  public: function(state: Object, maskingSet: Array, panelKey: string): boolean {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "public"], false)
  },
  private: function(state: Object, maskingSet: Array, panelKey: string): boolean {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "private"], false)
  },
  wheelchairAccessible: function(state: Object, maskingSet: Array, panelKey: string): boolean {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "wheelchairAccessible"], false)
  },
  careProviders: function(state: Object, maskingSet: Array, panelKey: string): Object {
    return _.chain(maskingSet)
      .map((record) => record.careProviderIds)
      .flatten()
      .uniq()
      .reduce((memo, id) => {
        return _.assign(
          { [id]: _.get(state, ["ui", "panels", panelKey, "filterValues", "careProviders", id], false) },
          memo
        );
      }, {})
      .value();
  },
  subcategories: function(state: Object, maskingSet: Array, panelKey: string): Object {
    var panelCategoryId = panelKey.match(/\d/g).join("");

    return _.chain(maskingSet)
     .map((record) => record.categoryId)
     .flatten()
     .uniq()
     .pull([ parseInt(panelCategoryId) ])
     .reduce((memo, id) => {
       return _.assign(
         { [id]: _.get(state, ["ui", "panels", panelKey, "filterValues", "subcategories", id], false) },
         memo
       );
     }, {})
     .value();
  },
  specializationFilterActivated: function(state: Object, maskingSet: Array, panelKey: string): boolean {
    return _.get(state, ["ui", "panels", panelKey, "filterValues", "specializationFilterActivated"], false);
  }
}
