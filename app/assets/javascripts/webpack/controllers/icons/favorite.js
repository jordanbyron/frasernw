import React from "react";
import { buttonIsh} from "stylesets";
import _ from "lodash";

const FavoriteIcon = ({model, dispatch, record}) => {
  if (isFavorited(model, record)) {
    return(
      <i
        className="icon-heart icon-red"
        onClick={_.partial(handleUnFavorite, record, dispatch)}
        style={buttonIsh}
        title="Unfavourite this item"
      />
    );
  } else {
    return(
      <i
        className="icon-heart"
        onClick={_.partial(handleFavorite, record, dispatch)}
        style={_.assign({}, buttonIsh, {color: "#424242"})}
        title="Favourite this item"
      />
    );
  }
}

const updateServer = (record) => {
  return $.ajax({
    url: `/favorites/${_.snakeCase(record.collectionName)}/${record.id}`,
    type: "PATCH",
    data: "",
    dataType: 'json'
  });
}

const handleFavorite = (record, dispatch) => {
  updateServer(record).success(() => {
    dispatch({
      type: "FAVORITED_ITEM",
      id: record.id,
      itemType: record.collectionName
    });
  })
};

const handleUnFavorite = (record, dispatch) => {
  updateServer(record).success(() => {
    dispatch({
      type: "UNFAVORITED_ITEM",
      id: record.id,
      itemType: record.collectionName
    });
  })
};

const isFavorited = (model, record) => {
  return model.
    app.
    currentUser.
    favorites[record.collectionName].
    pwPipe((favorites) => _.includes(favorites, record.id));
}

export default FavoriteIcon;
