// Wrapper to hook into updates

// This wrapper requires:
// A store created at the address the props specify, which defines the
// following functions in the clientFunctions namespace:
// getData(): returns table data
// setUpdateListener(callback): sets a listener which executes the provided
// callback when data is updated

var TableWithStore = React.createClass({
  store: function() {
    return window.pathways.tableDataStores[this.props.storeAddress];
  },
  retrieveStoreUpdates: function() {
    return this.store().clientFunctions.getData;
  },
  setStoreUpdateListener: function( onStoreUpdate ) {
    return this.store().clientFunctions.setUpdateListener;
  },
  render: function() {
    return (
      <Table retrieveDataUpdates={this.retrieveStoreUpdates()} setDataUpdateListener={this.setStoreUpdateListener()}/>
    );
  }
});
