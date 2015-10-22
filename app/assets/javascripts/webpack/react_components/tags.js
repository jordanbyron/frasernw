var React = require("react");

let TAGS = [
  { key: "isGp", element: <span  style={{marginLeft: "5px"}} className="gp" key="gp">GP</span> },
  { key: "isNew", element: <span  style={{marginLeft: "5px"}} className="new" key="new">new</span> },
  { key: "private", element: <span  style={{marginLeft: "5px"}} className="private" key="private">private</span> }
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
