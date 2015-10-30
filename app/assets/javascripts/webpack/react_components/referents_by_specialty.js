var React = require("react");
var LoadingContainer = require("./loading_container");
var List = require("./list");
var SidebarLayout = require("./sidebar_layout");
var Filters = require("./filters");
var TableRow = require("./table_row");
var TableHead = require("./table_head");

var Lists = React.createClass({
  propTypes: {
    lists: React.PropTypes.arrayOf(React.PropTypes.shape({
      title: React.PropTypes.string,
      entries: React.PropTypes.arrayOf(React.PropTypes.object)
    }))
  },
  render: function() {
    return (
      <div className="lists">
        {
          this.props.lists.map((list) => <List key={list.key} {...list}/>)
        }
      </div>
    );
  }
})

var Table = React.createClass({
  propTypes: {
    rows: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        reactKey: React.PropTypes.node,
        data: React.PropTypes.array
      })
    )
  },
  render: function() {
    return (
      <table className="table">
        <TableHead {...this.props.tableHead} dispatch={this.props.dispatch}/>
        <tbody>
          {
            this.props.rows.map((row) => {
              return(<TableRow {...row} key={row.reactKey} data={row.cells}/>);
            })
          }
        </tbody>
      </table>
    );
  }
})

const CONTENT_COMPONENTS = {
  expanded: Lists,
  summary: Table
}

module.exports = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    contentComponentType: React.PropTypes.string,
    contentComponentProps: React.PropTypes.object,
    isLoading: React.PropTypes.bool
  },
  renderChildren: function(props) {
    return(
      <div className="content-wrapper">
        <SidebarLayout
          main={
            <div id="print_container">
              <h2 style={{marginBottom: "10px"}}>{ props.title }</h2>
              {
                React.createElement(
                  CONTENT_COMPONENTS[this.props.contentComponentType],
                  this.props.contentComponentProps
                )
              }
            </div>
          }
          sidebar={
            <Filters
              {...this.props.filters}
              dispatch={this.props.dispatch}
            />
          }
          reducedView={"main"}
        />
      </div>
    );
  },
  render: function() {
    return(
      <LoadingContainer
        isLoading={this.props.isLoading}
        renderChildren={this.renderChildren.bind(null, this.props)}
      />
    );
  }
});
