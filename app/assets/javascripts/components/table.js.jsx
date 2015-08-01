var Table = React.createClass({
  componentWillMount: function() {
    this.setState({
      data: {
        bodyRows: [],
        headings: []
      }
    });
    this.props.setDataUpdateListener(this.onDataSourceUpdate);
    this.onDataSourceUpdate();
  },
  onDataSourceUpdate: function() {
    this.setState(
      { data: this.props.retrieveDataUpdates() }
    );
  },
  render: function() {
    return (
      <table>
        <TableHead data={this.state.data.headings}/>
        <TableBody rows={this.state.data.bodyRows}/>
      </table>
    );
  }
});
