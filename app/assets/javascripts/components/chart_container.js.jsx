BASE_PATH = "/api/v1/analytics"
var ChartContainer = React.createClass({
  getDefaultProps: function() {
    return {
      months: [],
    };
  },
  componentDidMount: function() {
    $(document).on("dimensionChanged", this.updateSeries)
  },
  updateSeries: function(e) {
    this.setState({seriesKey: parseInt(e.key)});
  },
  getInitialState: function(){
    return {
      series: [],
    };
  },
  render: function() {
    return (
      <div>
        <TimeSeriesChart months={this.props.months}/>
      </div>
    );
  }
});
