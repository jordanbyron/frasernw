import React from "react";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import { memoizePerRender } from "utils";
import ReferentStatusIcon from "controllers/referent_status_icon";
import Tags from "component_helpers/tags";
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
    <td className="datatable__cell" key="wt">
      { model.app.consultationWaitTimes[decoratedRecord.consultationWaitTimeKey] }
    </td>,
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
        <Suffix record={decoratedRecord.raw} model={model}/>
        <Tags record={decoratedRecord.raw}/>
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

const Suffix = ({record, model}) => {
  return(
    <span style={{marginLeft: "5px"}} className="suffix" key="suffix">
      {suffix(record, model)}
    </span>
  )
}

const suffix = (record, model) => {
  if (record.collectionName === "clinics") {
    return "";
  }
  else if (record.isGp) {
    return "GP";
  }
  else if (record.isInternalMedicine) {
    return "Int Med";
  }
  else if (showPedSuffix(record, model)) {
    return "Ped";
  }
  else {
    return _.find(
      record.specializationIds.map((id) => model.app.specializations[id].suffix),
      (suffix) => suffix && suffix.length > 0
    );
  }
};

const showPedSuffix = (record, model) => {
  return record.seesOnlyChildren &&
    record.specializationIds.length > 1 &&
    isPediatrician(record, model) &&
    (route !== "/specialties/:id" ||
      recordShownByRoute(model).id !== parseInt(pediatricsId(model)));
}

const pediatricsId = ((model) => {
  return _.find(
    model.app.specializations,
    (specialization) => specialization.name === "Pediatrics"
  ).id;
}).pwPipe(memoizePerRender)

const isPediatrician = (record, model) => {
  return _.includes(record.specializationIds, parseInt(pediatricsId(model)));
}


export default ReferentRow;
