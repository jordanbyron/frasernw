var Table = React.createClass({
  generateRows: function(records) {
    return records.map(this.generateRow);
  },
  generateRow: function(record) {
    return this.rowGenerator().map(function(fn) {
      return fn(record);
    })
  },
  rowGenerator: function() {
    return window.pathways.rowGenerators[this.props.rowGenerator];
  },
  render: function() {
    return (
      <table>
        <TableHead data={this.props.headings}/>
        <TableBody rows={this.generateRows(this.props.records)}/>
      </table>
    );
  }
});
