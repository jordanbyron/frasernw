var Table = React.createClass({
  render: function() {
    return (
      <table>
        <TableBody rows={this.props.rows}/>
      </table>
    );
  }
});
