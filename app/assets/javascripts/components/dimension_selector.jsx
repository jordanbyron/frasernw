var DimensionSelector = React.createClass({
  emitChanged: function(e) {
    target = $(event.target);
    $(document).trigger({type: "seriesChanged", key: target.val()});
  },
  render: function() {
    var optionNodes = this.props.options.map(function(option, index) {
      return (
        <option key={index} value={option.key}>
          {option.name}
        </option>
      );
    });
    return (
      <select onChange={this.emitChanged} value={this.props.selectedOption}>
        {optionNodes}
      </select>
    );
  }
});
