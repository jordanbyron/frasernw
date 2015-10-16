var React = require("react");
var LoadingContainer = require("./loading_container");
var SidebarLayout = require("./sidebar_layout");
var Filters = require("./filters");

module.exports = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    tableRows: React.PropTypes.array,
    filters: React.PropTypes.object,
    isLoading: React.PropTypes.bool
  },
  renderChildren: function(props) {
    return(
      <div className="content-wrapper">
        <SidebarLayout
          main={
            <div>
              <h2 style={{marginBottom: "10px"}}>{ props.title }</h2>
              <table className="table">
                <tbody>
                  {
                    props.tableRows.map((row) => {
                      return(
                        <tr><td>{ row }</td></tr>
                      )
                    })
                  }
                </tbody>
              </table>
            </div>
          }
          sidebar={
            <Filters
              {...props.filters}
              dispatch={props.dispatch}
            />
          }
          reducedView={"main"}
        />
      </div>
    );
  },
  render: function() {
    console.log(this.props);
    return(
      <LoadingContainer
        isLoading={this.props.isLoading}
        renderChildren={this.renderChildren.bind(null, this.props)}
      />
    )
  }
})
