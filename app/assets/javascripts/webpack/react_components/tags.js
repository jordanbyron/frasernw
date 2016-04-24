var React = require("react");

module.exports = React.createClass({
  render: function() {
    let tags = [];

    if (this.props.record.isNew){
      tags.push(
        <span style={{marginLeft: "5px"}} className="new" key="new">new</span>
      );
    }

    if (this.props.record.isPrivate && !this.props.record.isPublic){
      tags.push(
        <span style={{marginLeft: "5px"}} className="private" key="isPrivate">
          private
        </span>
      );
    }

    return(<span>{tags}</span>);
  }
})
