var React = require("react");
var buttonIsh = require("../../stylesets").buttonIsh
var objectAssign = require("object-assign");

module.exports = React.createClass({
  updateServer: function() {
    return $.ajax({
      url: ('/favorites/' + this.props.collectionPath + '/' + this.props.record.id),
      type: "PATCH",
      data: "",
      dataType: 'json'
    });
  },
  handleFavorite: function() {
    this.updateServer().success(() => {
      this.props.dispatch({
        type: "FAVORITED_ITEM",
        id: this.props.record.id,
        itemType: this.props.collection
      })
    })
  },
  handleUnFavorite: function() {
    this.updateServer().success(() => {
      this.props.dispatch({
        type: "UNFAVORITED_ITEM",
        id: this.props.record.id,
        itemType: this.props.collection
      })
    })
  },
  favorited: function() {
    return (this.props.favorites[this.props.collection].indexOf(this.props.record.id) > -1);
  },
  render: function(){
    if (this.favorited()) {
      return(<i
        className="icon-heart icon-red"
        onClick={this.handleUnFavorite}
        style={buttonIsh}
        title="Unfavourite this item"
      />);
    } else {
      return(<i
        className="icon-heart"
        onClick={this.handleFavorite}
        style={objectAssign({}, buttonIsh, {color: "#424242"})}
        title="Favourite this item"
      />);
    }
  }
})
