import React from "react";
import TableRow from "controllers/table_row";
import { route } from "controller_helpers/routing";
import { unscopedCollectionShown, collectionShownName }
  from "controller_helpers/collection_shown";
import sortOrders from "controller_helpers/sort_orders";
import sortIteratees from "controller_helpers/sort_iteratees";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import recordsToDisplay from "controller_helpers/records_to_display";
import * as filterValues from "controller_helpers/filter_values";
import sidebarFilters from "controller_helpers/sidebar_filters";
import { paginate } from "controller_helpers/pagination";
import { useProcedureSpecificWaitTimes, specificWaitTimeProcedureId }
  from "controller_helpers/procedure_specific_wait_times";
import _ from "lodash";

const TableRows = (model, dispatch) => {
  return recordsToDisplay(model).
    map((record) => decorate(record, model)).
    pwPipe((decoratedRecords) => {
      return _.sortByOrder(decoratedRecords, sortIteratees(model), sortOrders(model));
    }).pwPipe((decoratedRecords) => {
      if(route === "/news_items") {
        return paginate(model, decoratedRecords)
      }
      else {
        return decoratedRecords;
      }
    }).map((decoratedRecord) => {
      return(
        <TableRow key={decoratedRecord.reactKey}
          decoratedRecord={decoratedRecord}
          model={model}
          dispatch={dispatch}
        />
      );
    });
};

const decorate = (record, model) => {
  let decorated = { raw: record };

  if (route === "/latest_updates") {
    decorated.reactKey = _.values(_.omit(record, "markup")).join(".")
  }
  else {
    decorated.reactKey = `${record.collectionName}${record.id}`;
  }

  if(_.includes([
    "/specialties/:id",
    "/areas_of_practice/:id",
    "/content_categories/:id",
    "/hospitals/:id",
    "/languages/:id"
  ], route)) {

    if(_.includes(["specialists", "clinics"], collectionShownName(model))) {
      if(showingMultipleSpecializations(model)) {
        decorated.specializationNames = record.specializationIds.map((id) => {
          return model.app.specializations[id].name;
        }).sort().join(" and ");
      }

      decorated.cityNames = record.cityIds.map((id) => {
        return model.app.cities[id].name;
      }).sort().join(" and ");
      decorated.adjustedConsultationWaitTimeKey = labelReferentWaittime(record, model);
    }
    else if (collectionShownName(model) === "contentItems") {
      decorated.subcategoryName =
        model.app.contentCategories[record.categoryId].name;
    }
  }
  else if (route === "/reports/referents_by_specialty" &&
    filterValues.reportStyle(model) === "summary") {

      decorated.count = model.app[filterValues.entityType(model)].
        pwPipe(_.values).
        filter((referent) => {
          if(sidebarFilters.divisionScope.isActivated(model)){
            return _.includes(
              referent.divisionIds,
              parseInt(filterValues.divisionScope(model))
            ) && _.includes(referent.specializationIds, record.id)
          }
          else {
            return _.includes(referent.specializationIds, record.id);
          }
        }).length
  }
  else if (route === "/news_items"){
    decorated.ownerDivisionName = model.app.divisions[record.ownerDivisionId].name;
  }

  return decorated;
};

const labelReferentWaittime = (record, model) => {
  if(useProcedureSpecificWaitTimes(model)){
    return record.procedureSpecificConsultationWaitTimes[specificWaitTimeProcedureId(model)];
  } else {
    return record.consultationWaitTimeKey;
  }
};

export default TableRows;
