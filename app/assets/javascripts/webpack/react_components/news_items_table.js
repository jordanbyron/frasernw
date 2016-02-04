import React from "react";
import NavTabs from "react_components/nav_tabs";
import Pagination from "react_components/pagination";
import _ from "lodash";
import { from } from "utils";

const NewsItemsTable = React.createClass({
  getInitialState() {
    return {
      selectedTab: "OWNED"
    };
  },
  render() {
    const _row = _.partial(
      row,
      this.props.app.divisions,
      this.props.app.currentUser,
      this.state.selectedTab,
      this.props.ui.divisionId
    );

    const _shouldDisplayRecord = _.partial(
      shouldDisplayRecord,
      this.props.ui.divisionId,
      this.state.selectedTab
    )
    const _currentPage = (this.state.currentPage || 1);

    const _filtered = from(
      _.partialRight(_.filter, _shouldDisplayRecord),
      _.values(this.props.app.newsItems)
    )

    const _bodyRows = from(
      _.partialRight(_.map, _row),
      _.partial(paginate, _currentPage, ROWS_PER_PAGE),
      _.partialRight(_.sortByOrder, [ "startDate" ], [ "desc" ]),
      _filtered
    );

    const _paginationProps = {
      currentPage: _currentPage,
      setPage: _.partial(function(table, page, event) {
        table.setState({currentPage: page});
      }, this),
      totalPages: _.ceil(_filtered.length / ROWS_PER_PAGE)
    }

    return(
      <div className="tabbable">
        <NavTabs {...navTabsProps(this)}/>
        <table className="table table-condensed table-striped">
          <thead>
            <tr>
              <th>Title</th>
              <th>Division</th>
              <th>Type</th>
              <th>Date</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            { _bodyRows }
          </tbody>
        </table>
        <Pagination {..._paginationProps}/>
      </div>
    )
  }
});


const navTabsProps = (page) => {
  return {
    tabs: [
      {
        label: "Owned (Editable)",
        key: "OWNED"
      },
      {
        label: "Currently Showing",
        key: "SHOWING"
      },
      {
        label: "Available from Other Divisions",
        key: "AVAILABLE"
      }
    ],
    selectedTab: page.state.selectedTab,
    onTabClick: function(key) { return function() { page.setState({selectedTab: key }) }}
  };
}

const DateCell = (props) => (
  <div>
    {
      [
        { key: "startDate", label: "Start: " },
        { key: "endDate", label: "End: "}
      ].filter((pair) => props.record[pair.key]).map((pair) => (
        <div key={pair.key}>
          <b>{ pair.label }</b>
          <span>{ props.record[pair.key] }</span>
        </div>
      ))
    }
  </div>
);

const shouldAllowDelete = (record, currentUser) => (
  _.includes(currentUser.divisionIds, record.ownerDivisionId) ||
    currentUser.isSuperAdmin
);


const EditButton = (props) => (
  <a
    href={`/news_items/${props.record.id}/edit`}
    className="btn btn-mini button--right_margin"
  >
    <i className="icon icon-pencil icon--right_margin"/>
    <span>Edit</span>
  </a>
);

const DeleteButton = (props) => {
  return(
    <a
      href={`/news_items/${props.record.id}`}
      dataMethod="delete"
      className="btn btn-mini button--right_margin"
    >
      <i className="icon icon-trash icon--right_margin"/>
      <span>Delete</span>
    </a>
  );
}

const ViewButton = (props) => (
  <a
    href={`/news_items/${props.record.id}`}
    className="btn btn-mini button--right_margin"
  >
    <span>View</span>
  </a>
)

const CopyButton = ({record, tabKey, divisionId}) => {
  if(tabKey === "AVAILABLE"){
    return(
      <a
        href={`/news_items/${record.id}/copy/?target_division_id=${divisionId}`}
        className="btn btn-mini"
        data-method="post"
      >
        <i className="icon icon-copy icon--right_margin"/>
        <span>Copy</span>
      </a>
    );
  } else {
    return <div></div>;
  }
};

const ActionCell = (props) => {
  if(shouldAllowDelete(props.record, props.currentUser)) {
    return (
      <div>
        <EditButton {...props}/>
        <DeleteButton {...props}/>
        <CopyButton {..._.pick(props, ["tabKey", "record", "divisionId"])}/>
      </div>
    )
  } else {
    return(
      <div>
        <ViewButton {...props}/>
        <CopyButton {..._.pick(props, ["tabKey", "record", "divisionId"])}/>
      </div>
    );
  }
}

const row = (divisions, currentUser, tabKey, divisionId, record) => {
  return(
    <tr key={record.id}>
      <td><a href={`/news_items/${record.id}`}>{ _.trunc(record.title, 40) }</a></td>
      <td>{ divisions[record.ownerDivisionId].name }</td>
      <td>{ record.type }</td>
      <td><DateCell record={record}/></td>
      <td>
        <ActionCell
          record={record}
          currentUser={currentUser}
          tabKey={tabKey}
          divisionId={divisionId}
        />
      </td>
    </tr>
  );
}

const shouldDisplayRecord = (divisionId, tabKey, record) => {
  switch(tabKey){
  case "OWNED":
    return divisionId === record.ownerDivisionId;
  case "SHOWING":
    return (record.isCurrent &&
      _.includes(record.divisionDisplayIds, divisionId));
  case "AVAILABLE":
    return !(divisionId === record.ownerDivisionId);
  }
}


const paginate = (currentPage, rowsPerPage, array) => {
  let startIndex = (currentPage - 1) * rowsPerPage;
  let endIndex = (currentPage * rowsPerPage);

  return array.slice(startIndex, endIndex);
}

const ROWS_PER_PAGE = 30;

export default NewsItemsTable;
