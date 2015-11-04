import React from "react";
import LoadingContainer from "react_components/loading_container";
import Filters from "react_components/filters";
import SidebarLayout from "react_components/sidebar_layout";
import TableHead from "react_components/table_head";
//
// var Table = React.createClass({
//   propTypes: {
//     rows: React.PropTypes.arrayOf(
//       React.PropTypes.shape({
//         reactKey: React.PropTypes.node,
//         data: React.PropTypes.array
//       })
//     )
//   },
//   render: function() {
//     return (
//       <table className="table">
//         <TableHead {...this.props.tableHead} dispatch={this.props.dispatch}/>
//         <tbody>
//           {
//             this.props.rows.map((row) => {
//               return(<TableRow {...row} key={row.reactKey} data={row.cells}/>);
//             })
//           }
//         </tbody>
//       </table>
//     );
//   }
// })
//
// const CONTENT_COMPONENTS = {
//   expanded: Lists,
//   summary: Table
// }
//
// module.exports = React.createClass({
//   propTypes: {
//     title: React.PropTypes.string,
//     contentComponentType: React.PropTypes.string,
//     contentComponentProps: React.PropTypes.object,
//     isLoading: React.PropTypes.bool
//   },
//     );
//   },
//   render: function() {
//     return(
//       <LoadingContainer
//         isLoading={this.props.isLoading}
//         renderContents={this.renderContents.bind(null, this.props)}
//       />
//     );
//   }
// });


const MainPanel = (props) => (
  <table className="table">
    <TableHead {...props.tableHead} dispatch={props.dispatch}/>
  </table>
)

const CategoryPageContents = (props) => (
  <SidebarLayout
    main={<MainPanel {...props}/>}
    sidebar={<Filters {...props.filters}/>}
    reducedView={"main"}
  />
);

const CategoryPage = (props) => (
  <LoadingContainer
    isLoading={props.isLoading}
    renderContents={CategoryPageContents.bind(null, props)}
  />
);

export default CategoryPage;
