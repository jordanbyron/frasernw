import React from "react";
import _ from "lodash"
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const TableRow = ({model, dispatch, decoratedRecord}) => {
  return(
    <tr>
      <td>
        <a href={`/news_items/${decoratedRecord.raw.id}`}>
          { _.trunc(decoratedRecord.raw.title, 40) }
        </a>
      </td>
      <td>{ decoratedRecord.ownerDivisionName }</td>
      <td>{ decoratedRecord.raw.type }</td>
      <td><DateCell record={decoratedRecord.raw}/></td>
      <td><ActionCell record={decoratedRecord.raw} model={model}/></td>
    </tr>
  );
}

const DateCell = ({record}) => (
  <div>
    {
      [
        { key: "startDate", label: "Start: " },
        { key: "endDate", label: "End: "}
      ].filter((pair) => record[pair.key]).map((pair) => (
        <div key={pair.key}>
          <b>{ pair.label }</b>
          <span>{ record[pair.key] }</span>
        </div>
      ))
    }
  </div>
);


const ActionCell = ({record, model}) => {
  return (
    <div>
      <EditButton record={record} model={model}/>
      <DeleteButton record={record} model={model}/>
      <ViewButton record={record} model={model}/>
      <CopyButton record={record} model={model}/>
    </div>
  )
};

const EditButton = ({record, model}) => {
  if(shouldAllowDelete(record, model)) {
    return(
      <a
        href={`/news_items/${record.id}/edit`}
        className="btn btn-mini button--right_margin"
      >
        <i className="icon icon-pencil icon--right_margin"/>
        <span>Edit</span>
      </a>
    )
  }
  else {
    return <noscript/>
  }
};

const DeleteButton = ({record, model}) => {
  if(shouldAllowDelete(record, model)) {
    return(
      <a
        href={`/news_items/${record.id}`}
        data-method="delete"
        data-confirm={`Delete ${record.title}?`}
        className="btn btn-mini button--right_margin"
      >
        <i className="icon icon-trash icon--right_margin"/>
        <span>Delete</span>
      </a>
    );
  }
  else {
    return <noscript/>
  }
};

const CopyButton = ({record, model}) => {
  if(selectedTabKey(model) === "availableNewsItems") {
    return(
      <a
        href={
          "/news_items/" +
          record.id +
          "/copy/?target_division_id=" +
          model.ui.persistentConfig.divisionId
        }
        className="btn btn-mini"
        data-method="post"
      >
        <i className="icon icon-copy icon--right_margin"/>
        <span>Copy</span>
      </a>
    );
  }
  else {
    return <noscript/>
  }
};

const ViewButton = ({record, model}) => {
  if(!shouldAllowDelete(record, model)) {
    return(
      <a
        href={`/news_items/${record.id}`}
        className="btn btn-mini button--right_margin"
      >
        <span>View</span>
      </a>
    );
  }
  else {
    return <noscript/>
  }
};


const shouldAllowDelete = (record, model) => {
  return _.includes(model.app.currentUser.divisionIds, record.ownerDivisionId) ||
    model.app.currentUser.role === "super"
};

export default TableRow;
