var React = require("react");
var LoadingContainer = require("./loading_container");
var List = require("./list");

module.exports = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    lists: React.PropTypes.arrayOf(React.PropTypes.shape({
      title: React.PropTypes.string,
      entries: React.PropTypes.arrayOf(React.PropTypes.string)
    })),
    isLoading: React.PropTypes.bool
  },
  renderChildren: function(props) {
    return(
      <div className="content-wrapper">
        <h2>{ props.title }</h2>
        <div className="lists">
          {
            props.lists.map((list) => <List key={list.key} {...list}/>)
          }
        </div>
      </div>
    );
  },
  render: function() {
    console.log(this.props);
    return(
      <LoadingContainer
        isLoading={this.props.isLoading}
        renderChildren={this.renderChildren}
        childrenProps={this.props}
      />
    );
  }
});
