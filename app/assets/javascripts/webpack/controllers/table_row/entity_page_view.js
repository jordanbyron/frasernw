import React from "react";
import * as filterValues from "controller_helpers/filter_values";

const EntityPageViewRow = ({decoratedRecord, model}) => {
  return(
    <tr key={decoratedRecord.reactKey}>
      <td dangerouslySetInnerHTML={{__html: decoratedRecord.raw.link}}/>
      <EntityDivisions model={model} decoratedRecord={decoratedRecord}/>
      <td key="count">{ decoratedRecord.raw.usage }</td>
    </tr>
  )
}

const EntityDivisions = ({decoratedRecord, model}) => {
  if (["clinics","specialists"].includes(filterValues.entityType(model))) {
    return(
      <td>
        <span>{ entityDivisionNames(decoratedRecord, model) }</span>
      </td>
    )
  }
  else {
    return(
      <td></td>
    )
  }
}

const entityDivisionNames = (decoratedRecord, model) => {
  return (
    model.app[filterValues.entityType(model)][decoratedRecord.raw.id].
      divisionIds.map((id) => model.app.divisions[id].name).
      sort().
      to_sentence()
  )
}

export default EntityPageViewRow;
