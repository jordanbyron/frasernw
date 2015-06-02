var STATIC_CONFIG = {
  yAxis: {
    title: {
      text: 'Value'
    }
  }
};

var TimeSeriesChart = React.createClass({
  chartConfig: function() {
    $.extend({
      xAxis: {
        categories: this.props.months
      },
      series: {
        data: []
      }
    }, STATIC_CONFIG);
  },
  createChart: function() {
    $('#chartContainer').highcharts(this.chartConfig());
  },
  componentDidMount: function() {
    this.createChart();
  },
  shouldComponentUpdate: function() {
    return true;
  },
  componentDidUpdate: function() {
    this.createChart();
  },
  render: function() {
    return (
      <div id="chartContainer" style={{minWidth: "310px", height: "400px", margin: "0 auto"}}>
      </div>
    );
  }
});
