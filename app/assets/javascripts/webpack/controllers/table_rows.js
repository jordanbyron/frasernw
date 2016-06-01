import React from "react";
import TableRow from "controllers/table_row";
import { matchedRoute } from "controller_helpers/routing";
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
import _ from "lodash";

const TableRows = (model, dispatch) => {
  return recordsToDisplay(model).
    map((record) => decorate(record, model)).
    pwPipe((decoratedRecords) => {
      return _.sortByOrder(decoratedRecords, sortIteratees(model), sortOrders(model));
    }).pwPipe((decoratedRecords) => {
      if(matchedRoute(model) === "/news_items") {
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

  if (matchedRoute(model) === "/latest_updates") {
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
  ], matchedRoute(model))) {

    if(_.includes(["specialists", "clinics"], collectionShownName(model))) {
      if(showingMultipleSpecializations(model)) {
        decorated.specializationNames = record.specializationIds.map((id) => {
          return model.app.specializations[id].name;
        }).sort().join(" and ");
      }

      decorated.cityNames = record.cityIds.map((id) => {
        return model.app.cities[id].name;
      }).sort().join(" and ");
    }
    else if (collectionShownName(model) === "contentItems") {
      decorated.subcategoryName =
        model.app.contentCategories[record.categoryId].name;
    }
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty" &&
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
  else if (matchedRoute(model) === "/news_items"){
    decorated.ownerDivisionName = model.app.divisions[record.ownerDivisionId].name;
  }

  return decorated;
};

export default TableRows;
