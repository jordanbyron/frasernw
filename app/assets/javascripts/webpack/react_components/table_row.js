var React = require("react");

module.exports = React.createClass({
  // IMPORTANT: here we're going to assume that table rows stay the same
  // once they're created
  shouldComponentUpdate: function() {
    return false;
  },
  render: function() {
    return (
      <tr>
        {
          this.props.data.map(function(cell, i) {
            return (
              <td key={i}>{cell}</td>
            );
          })
        }
      </tr>
    );
  }
});
