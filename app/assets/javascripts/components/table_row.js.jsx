var TableRow = React.createClass({
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
