var Table = React.createClass({
  render: function() {
    return (
      <table>
        <TableHead data={this.props.headings}/>
        <TableBody rows={this.props.rows}/>
      </table>
    );
  }
});
