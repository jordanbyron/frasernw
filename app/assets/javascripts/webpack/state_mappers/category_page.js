import TableHeadingGenerators from "state_mappers/filter_table/table_headings_generators";
import { from } from "utils";
import RowGenerators from "state_mappers/filter_table/row_generators";
import itemsForCategory from "domain/content_category_items";
import SortFunctions from "state_mappers/filter_table/sort_functions";
import SortOrders from "state_mappers/filter_table/sort_orders";
import Filters from "state_mappers/filter_table/filters";
import resultSummary from "state_mappers/filter_table/generate_result_summary";
import anyFiltersActivated from "state_mappers/filter_table/any_filters_activated";
import React from "react";

export default function(state, dispatch) {
  // console.log(state);

  if(state.ui.hasBeenInitialized) {
    const _divisionIds = divisionIds(state);
    const _maskingSet =
      itemsForCategory(state.ui.contentCategoryId, state, _divisionIds);
    const _category = state.app.contentCategories[state.ui.contentCategoryId];
    const _componentType = _category.componentType

    return {
      componentProps: ComponentProps[_componentType](
        state,
        dispatch,
        _divisionIds,
        _maskingSet,
        _category
      ),
      componentType: _componentType,
      feedbackModal: feedbackModal(state),
      dispatch: dispatch,
    };
  }
  else {
    return { isLoading: true };
  }
};

const ComponentProps = {
  FilterTable: (state, dispatch, _divisionIds, _maskingSet, _category) => {
    const _sortConfig = sortConfig(state);
    const _filterValues =
      _.mapValues(FilterValues, (value) => value(state, _maskingSet));
    const _bodyRows =
      bodyRows(state, dispatch, _sortConfig, _maskingSet, _filterValues)
    const _resultSummary = resultSummary({
      app: state.app,
      bodyRows: _bodyRows,
      labelName: _category.name.toLowerCase(),
      panelTypeKey: "contentCategories",
      referralCities: [],
      filterValues: _filterValues,
      availableFilters: operativeFilterKeys
    });

    return {
      bodyRows: _bodyRows,
      resultSummary: {
        anyResults: (_bodyRows.length > 0),
        isVisible: (_resultSummary.length > 1),
        text: _resultSummary,
        showClearButton: anyFiltersActivated(state.ui.filterValues)
      },
      cityFilterPills: { shouldDisplay: false },
      specializationFilterMessage: { shouldDisplay: false },
      assumedList: { shouldDisplay: false },
      sortConfig: _sortConfig,
      headings: TableHeadingGenerators.contentCategories(),
      // TODO name this 'sidebarFilteringSection'
      filters: {
        title: `Filter ${_category.name}`,
        // TODO: name this 'sidebarFilteringSectionGroups'
        groups: _.map(FilterGroups, (group) => group(state, _filterValues, _maskingSet)),
      },
      reducedView: _.get(state, ["ui", "reducedView"], "main"),
      arbitraryFooter: arbitraryFooter(_category, state.app.contentCategories),
      dispatch: dispatch
    };
  },
  InlineArticles: (state, dispatch, _divisionIds, _maskingSet, _category) => {
    return {
      panelKey: "scCategory",
      records: _maskingSet,
      categoryLink: categoryLink(_category, state.app.categories),
      favorites: state.app.currentUser.favorites,
      dispatch: dispatch
    };
  }
}

const categoryLink = (category, categories) => {
  if(category.ancestry) {
    return {
      text: `Browse all ${categories[category.ancestry].name} content.`,
      link: `/content_categories/${category.ancestry}`
    }
  }
  else {
    return null;
  }
};

const arbitraryFooter = (category, categories) => {
  if(category.ancestry) {
    return(
      <a href={`/content_categories/${category.ancestry}`}>
        <i className='icon-arrow-right icon-blue' style={{margin: "0px 7px"}}/>
        <span>{`Browse all ${categories[category.ancestry].name} content`}</span>
      </a>
    );
  }
  else {
    return <div></div>;
  }
}

const feedbackModal = function(state) {
  return (state.ui.feedbackModal || { state: "HIDDEN"});
}

const operativeFilterKeys = ["subcategories", "specializations"];
const bodyRows = (state, dispatch, sortConfig, maskingSet, filterValues) => {
  const _operativeFilters = _.values(_.pick(Filters, operativeFilterKeys))
    .filter((filter) => filter.isActivated(filterValues))
    .map(_.property("predicate"));

  return from(
    _.partialRight(_.sortByOrder, SortFunctions.contentCategories(sortConfig), SortOrders.contentCategories(sortConfig)),
    _.partialRight(_.map, _.partial(RowGenerators.resources, state.app, dispatch, { panelKey: 0 })),
    _.partialRight(_.filter, (record) => _.every(_operativeFilters, (filter) => filter(record, filterValues))),
    maskingSet
  );
};

const divisionIds = (state) => {
  if(state.app.currentUser.isSuperAdmin) {
    return _.values(state.app.divisions).map(_.property("id")).concat([13, 11]);
  }
  else {
    return state.app.currentUser.divisionIds;
  }
}

const sortConfig = (state) => ({
  order: _.get(state, ["ui", "sortConfig", "order"], "DOWN"),
  column: _.get(state, ["ui", "sortConfig", "column"], "TITLE"),
})

const FilterValues = {
  subcategories: function(state, maskingSet) {
    return _.chain(maskingSet)
     .map((record) => record.categoryId)
     .flatten()
     .uniq()
     .without(state.ui.contentCategoryId)
     .reduce((memo, id) => {
       return _.assign(
         { [id]: _.get(state, ["ui", "filterValues", "subcategories", id], false) },
         memo
       );
     }, {})
     .value();
  },
  specializations: function(state, maskingSet) {
    return _.get(state, ["ui", "filterValues", "specializations"], "0");
  }
}

const FilterGroups = {
  subcategories: function(state: Object, filterValues: Object): Object {
    return {
      filters: {
        subcategories: _.sortBy(_.map(
          filterValues.subcategories,
          function(value: boolean, subcategoryId: string) {
            return {
              filterId: subcategoryId,
              label: state.app.contentCategories[subcategoryId].name,
              value: value
            };
          }
        ), "label"),
      },
      title: "Subcategories",
      isOpen: _.get(state, ["ui" ,"filterGroupVisibility", "subcategories"], true),
      shouldDisplay: _.any(_.keys(filterValues.subcategories)),
      componentKey: "subcategories",
    };
  },
  specializations: function(state: Object, filterValues: Object, maskingSet: Array): Object {
    const createOption = function(specializationId) {
      return {
        key: `${specializationId}`,
        checked: (`${specializationId}` === filterValues.specializations),
        label: state.app.specializations[specializationId].name
      };
    };
    const allSpecialtiesOption = {
      key: "0",
      checked: "0" === filterValues.specializations,
      label: "All"
    };

    const options = from(
      Array.prototype.concat.bind(allSpecialtiesOption),
      _.partialRight(_.sortBy, "label"),
      _.partialRight(_.map, createOption),
      _.uniq,
      _.flatten,
      _.partialRight(_.map, _.property("specializationIds")),
      maskingSet
    );

    return {
      filters: {
        specializations: { options: options }
      },
      title: "Specialties",
      isOpen: _.get(state, ["ui" ,"filterGroupVisibility", "specializations"], true),
      shouldDisplay: true,
      componentKey: "specializations",
    };

  },
}
