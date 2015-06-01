var chartConfig = {
  title: {
      text: 'Monthly Average Temperature',
      x: -20 //center
  },
  subtitle: {
      text: 'Source: WorldClimate.com',
      x: -20
  },
  xAxis: {
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  },
  yAxis: {
      title: {
          text: 'Temperature (°C)'
      },
      plotLines: [{
          value: 0,
          width: 1,
          color: '#808080'
      }]
  },
  tooltip: {
      valueSuffix: '°C'
  },
  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle',
      borderWidth: 0
  }
};

var TimeSeriesChart = React.createClass({
  createChart: function() {
    params = $.extend(chartConfig, {series: [ this.props.data] });
    $('#container').highcharts(params);
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
      <div id="container" style={{minWidth: "310px", height: "400px", margin: "0 auto"}}>
      </div>
    );
  }
});
