import * as filterValues from "controller_helpers/filter_values";
import recordsToDisplay from "controller_helpers/records_to_display";

const entityPageViews = (model) => {
  if (recordsToDisplay(model)){
    var sum = recordsToDisplay(model).
      map((record) => parseInt(record.usage)).
      pwPipe(_.sum)

    return (
      scopeLabel(model) +
      " on " +
      itemLabel(model) +
      ` (${sum} total)`
    );
  }
  else {
    return (
      scopeLabel(model) +
      " on " +
      itemLabel(model)
    );
  }
}

const itemLabel = (model) => {
  if (_.includes(
    ["specialists", "clinics", "specialties"],
    filterValues.entityType(model)
  )){
    return _.startCase(filterValues.entityType(model))
  }
  else if (filterValues.entityType(model) === "contentCategories"){
    return "Content Category Summary Pages";
  }
  else {
    return `'${_.startCase(filterValues.entityType(model))}' Items`;
  }
}

const scopeLabel = (model) => {
  if (parseInt(filterValues.divisionScope(model)) === 0) {
    return "Page Views";
  }
  else {
    return (
      model.app.divisions[filterValues.divisionScope(model)].name +
      " Users' Page Views"
    );
  }
}

export default entityPageViews;
