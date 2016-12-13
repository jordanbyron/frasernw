import React from "react";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import { memoizePerRender } from "utils";
import ReferentStatusIcon from "controllers/referent_status_icon";
import Tags from "controllers/tags";
import ExpandedReferentInformation from "controllers/expanded_referent_information";
import { route, recordShownByRoute } from "controller_helpers/routing";

const ReferentRow = ({decoratedRecord, model, dispatch}) => {
  return(
    <tr className={rowClass(decoratedRecord)}>
      { Cells(decoratedRecord, model, dispatch) }
    </tr>
  );
}

const Cells = (decoratedRecord, model, dispatch) => {
  let cells = [
    <ReferentName decoratedRecord={decoratedRecord} model={model} key="name"/>,
    <td className="datatable__cell" key="status">
      <ReferentStatusIcon model={model} record={decoratedRecord.raw} tooltip={true}/>
    </td>,
    <td className="datatable__cell" key="wt">{ decoratedRecord.waittime }</td>,
    <td className="datatable__cell" key="city">{ decoratedRecord.cityNames }</td>
  ]

  if(showingMultipleSpecializations(model)){
    cells.splice(
      1,
      0,
      <ReferentSpecializations decoratedRecord={decoratedRecord} model={model} key="spec"/>
    )
  }

  return cells;
}

const rowClass = (decoratedRecord) => {
  let rowClasses = [ "datatable__row" ]

  if(decoratedRecord.raw.hidden){
    rowClasses.push("hidden-from-users")
  }

  return rowClasses.join(" ");
}

const ReferentSpecializations = ({decoratedRecord}) => {
  return(
    <td  key="spec" className="datatable__cell">
      {decoratedRecord.specializationNames}
    </td>
  );
}

const ReferentName = ({decoratedRecord, model, dispatch}) => {
  return (
    <td className="datatable__cell">
      <span>
        <ReferentNameLink decoratedRecord={decoratedRecord}/>
        <Tags record={decoratedRecord.raw} model={model}/>
        <ExpandedReferentInformation record={decoratedRecord.raw} model={model}/>
      </span>
    </td>
  );
}

const ReferentNameLink = ({decoratedRecord}) => {
  return(
    <a className="datatable__referent_name"
      href={`/${decoratedRecord.raw.collectionName}/${decoratedRecord.raw.id}`}
    >
      { decoratedRecord.raw.name }
    </a>
  );
}
export default ReferentRow;
