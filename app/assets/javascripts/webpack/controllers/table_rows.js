import React from "react";
import TableRow from "controllers/table_row";
import { matchedRoute } from "controller_helpers/routing";
import { unscopedCollectionShown, collectionShownName }
  from "controller_helpers/collection_shown";
import sortOrders from "controller_helpers/sort_orders";
import sortIteratees from "controller_helpers/sort_iteratees";
import { showingOtherSpecializations } from "controller_helpers/filter_messages";
import recordsToDisplay from "controller_helpers/records_to_display";

const TableRows = (model, dispatch) => {
  const _sortIteratees = sortIteratees(model)
  const _sortOrders = sortOrders(model)

  return recordsToDisplay(model).
    map((record) => decorate(record, model)).
    pwPipe((decoratedRecords) => {
      return _.sortByOrder(decoratedRecords, _sortIteratees, _sortOrders);
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

  if(_.includes(["/specialties/:id", "/areas_of_practice/:id", "/content_categories/:id"],
    matchedRoute(model))) {

    decorated.reactKey = `${record.collectionName}${record.id}`;

    if(_.includes(["specialists", "clinics"], collectionShownName(model))) {
      if(showingOtherSpecializations(model)) {
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

  return decorated;
};

export default TableRows;
