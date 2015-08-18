var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <thead>
        <tr>
          {
            this.props.data.map(function(cell, i) {
              return (
                <th key={i}>{cell}</th>
              );
            })
          }
        </tr>
      </thead>
    );
  }
});
