import React from "react";
import NavTabs from "react_components/nav_tabs";
import _ from "lodash";
import { from } from "utils";


const navTabsProps = (page) => {
  return {
    tabs: [
      {
        label: "Owned News Items",
        key: "OWNED"
      },
      {
        label: "Borrowed News Items",
        key: "BORROWED"
      },
      {
        label: "Borrowable News Items",
        key: "BORROWABLE"
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

const shouldAllowEdit = (record, currentUser) => (
  _.includes(currentUser.divisionIds, record.ownerDivisionId) ||
    currentUser.isSuperAdmin
)

const EditCell = (props) => {
  if(shouldAllowEdit(props.record, props.currentUser)) {
    return (
      <div>
        <a
          href={`/news_items/edit/${props.record.id}`}
          className="btn btn-mini"
        >
          <i className="icon icon-pencil"/>
          <span>Edit</span>
        </a>
        <a
          href={`/news_items/${props.record.id}`}
          dataMethod="delete"
          className="btn btn-mini"
        >
          <i className="icon icon-trash"/>
          <span>Delete</span>
        </a>
      </div>
    )
  } else {
    return(
      <a
        href={`/news_items/${props.record.id}`}
        className="btn btn-mini"
      >Show</a>
    );
  }
}

const row = (divisions, currentUser, record) => {
  return(
    <tr key={record.id}>
      <td><a href={`/news_items/${record.id}`}>{ _.trunc(record.title, 40) }</a></td>
      <td>{ divisions[record.ownerDivisionId].name }</td>
      <td>{ record.type }</td>
      <td><DateCell record={record}/></td>
      <td><EditCell record={record} currentUser={currentUser}/></td>
    </tr>
  );
}

const shouldDisplayRecord = (divisionId, tabKey, record) => {
  switch(tabKey){
  case "OWNED":
    return divisionId === record.ownerDivisionId;
  case "BORROWED":
    return (!(divisionId === record.ownerDivisionId) &&
      _.includes(record.divisionDisplayIds, divisionId));
  case "BORROWABLE":
    return (!(divisionId === record.ownerDivisionId) &&
      !_.includes(record.divisionDisplayIds, divisionId));
  }
}

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
      this.props.app.currentUser
    );

    const _shouldDisplayRecord = _.partial(
      shouldDisplayRecord,
      this.props.ui.divisionId,
      this.state.selectedTab
    )

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
            {
              from(
                _.partialRight(_.map, _row),
                _.partialRight(_.sortByOrder, [ "startDate" ], [ "desc" ]),
                _.partialRight(_.filter, _shouldDisplayRecord),
                _.values(this.props.app.newsItems)
              )
            }
          </tbody>
        </table>
      </div>
    )
  }
})

export default NewsItemsTable;
