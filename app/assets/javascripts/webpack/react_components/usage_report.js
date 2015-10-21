var React = require("react");
var LoadingContainer = require("./loading_container");
var SidebarLayout = require("./sidebar_layout");
var ToggleBox = require("./toggle_box");

module.exports = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    tableRows: React.PropTypes.array,
    filters: React.PropTypes.object,
    isLoading: React.PropTypes.bool
  },
  renderChildren: function(props) {
    var toggleFilterGroupVisibility = function(dispatch, key, isOpen) {
      return ()=> {
        return dispatch({
          type: "TOGGLE_FILTER_GROUP_VISIBILITY",
          filterKey: key,
          isOpen: isOpen
        });
      }
    }

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
                        <tr key={row.link}>
                          <td dangerouslySetInnerHTML={{__html: row.link}}/>
                          <td>{ row.usage }</td>
                        </tr>
                      )
                    })
                  }
                </tbody>
              </table>
            </div>
          }
          sidebar={
            <div className="well filter">
              <div className="title" key="title">{ props.title }</div>
              {
                this.props.filters.groups.map((group, index) => {
                  return(
                    <ToggleBox
                      title={group.title}
                      open={group.isOpen}
                      handleToggle={toggleFilterGroupVisibility(props.dispatch, group.componentKey, group.isOpen)}
                      key={index}
                    >
                      { group.contents }
                    </ToggleBox>
                  );
                })
              }
            </div>
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
