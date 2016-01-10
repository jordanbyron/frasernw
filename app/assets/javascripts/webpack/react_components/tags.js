var React = require("react");
// TAGS are suffix labels displayed after Specialist names
// E.g. John Smith GP
let TAGS = [
  { key: "isNew", element: <span  style={{marginLeft: "5px"}} className="new" key="new">new</span> },
  { key: "isPrivate", element: <span  style={{marginLeft: "5px"}} className="private" key="isPrivate">private</span> }
]

module.exports = React.createClass({
  render: function() {
    var tags = TAGS
      .filter((tag) => this.props.record[tag.key])
      .map((tag) => tag.element)

    if (tags.length > 0) {
      return(<span>{ tags }</span>);
    } else {
      return null;
    }
  }
})
