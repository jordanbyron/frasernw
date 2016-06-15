import * as utils from "utils";
import _ from "lodash";
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import { matchedRoute } from "controller_helpers/routing";
import * as filterValues from "controller_helpers/filter_values";
import { memoizePerRender } from "utils";

const sidebarFilters = {
  cities: {
    isActivated: function(model) {
      return activatedFilterSubkeys.cities(model).length !==
        _.values(model.app.cities).length;
    },
    predicate: function(record, model) {

      return _.intersection(activatedFilterSubkeys.cities(model), record.cityIds).
        pwPipe(_.some)
    }
  },
  teleserviceRecipients: {
    isActivated: function(model) {
      return activatedFilterSubkeys.teleserviceRecipients(model).pwPipe(_.some)
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
    }
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
    }
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
    }
  },
  acceptsReferralsViaPhone: {
    isActivated: function(model) {
      return filterValues.acceptsReferralsViaPhone(model);
    },
    predicate: function(record, model) {
      return record.acceptsReferralsViaPhone;
    }
  },
  patientsCanCall: {
    isActivated: function(model) {
      return filterValues.patientsCanCall(model);
    },
    predicate: function(record, model) {
      return record.patientsCanCall;
    }
  },
  respondsWithin: {
    isActivated: function(model) {
      return parseInt(filterValues.respondsWithin(model)) !== 0;
    },
    predicate: function(record, model) {
      return (record.respondsWithin !== null &&
        record.respondsWithin <= parseInt(filterValues.respondsWithin(model)));
    }
  },
  sex: {
    isActivated: function(model) {
      return activatedFilterSubkeys.sex(model).length === 1;
    },
    predicate: function(record, model) {
      return filterValues.sex(model, record.sex);
    }
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
    }
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
    }
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
    }
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
    }
  },
  isPublic: {
    isActivated: function(model) {
      return filterValues.isPublic(model);
    },
    predicate: function(record, model) {
      return record.isPublic;
    }
  },
  isPrivate: {
    isActivated: function(model) {
      return filterValues.isPrivate(model);
    },
    predicate: function(record, model) {
      return record.isPrivate;
    }
  },
  interpreterAvailable: {
    isActivated: function(model) {
      return filterValues.interpreterAvailable(model);
    },
    predicate: function(record, model) {
      return record.interpreterAvailable;
    }
  },
  isWheelchairAccessible: {
    isActivated: function(model) {
      return filterValues.isWheelchairAccessible(model);
    },
    predicate: function(record, filters) {
      return record.wheelchairAccessible;
    }
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
    }
  },
  subcategories: {
    isActivated: function(model) {
      if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))){
        return activatedFilterSubkeys.subcategories(model).pwPipe(_.some);
      } else {
        return filterValues.subcategories(model) !== "0";
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
    }
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
    }
  },
  divisionScope: {
    isActivated: function(model) {
      return (parseInt(filterValues.divisionScope(model)) !== 0);
    },
    predicate: function(record, model) {
      return _.includes(
        record.divisionIds,
        parseInt(filterValues.divisionScope(model))
      );
    }
  },
  showHiddenUpdates: {
    isActivated: function(model) {
      return !filterValues.showHiddenUpdates(model)
        || model.app.currentUser.role === "user";
    },
    predicate: function(record) {
      return !record.hidden;
    }
  },
  completionDate: {
    isActivated: function(model) {
      return filterValues.completionDate(model) !== "0";
    },
    predicate: function(record, model) {
      if (filterValues.completionDate(model) === "4"){
        return record.completionEstimateKey === 4
      }
      else {
        return parseInt(record.completionEstimateKey) <=
          parseInt(filterValues.completionDate(model));
      }
    }
  },
  assignees: {
    isActivated: function(model) {
      return filterValues.assignees(model) !== "All";
    },
    predicate: function(record, model) {
      return filterValues.assignees(model) === record.assigneesLabel;
    }
  },
  issueSource: {
    isActivated: function(model) {
      return filterValues.issueSource(model) !== "0";
    },
    predicate: function(record, model) {
      return record.sourceKey === parseInt(filterValues.issueSource(model));
    }
  },
  priority: {
    isActivated: function(model) {
      return filterValues.priority(model) !== "0";
    },
    predicate: function(record, model) {
      return record.priority === filterValues.priority(model).toString();
    }
  }
}

export default sidebarFilters;
