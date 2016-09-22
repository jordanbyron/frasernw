const scoreString = (queryTokensSearchers, queried) => {
  const _queriedTokens = queried.split(/\s+/g)

  const _queryTokensMatches = queryTokensSearchers.map((searcher) => {
    return _queriedTokens.
      reduce((bestMatch, queriedToken, queriedTokenIndex) => {

      const _searchResult = searcher.search(queriedToken)
      const _score = (1 - _searchResult.score);

      if (_searchResult.isMatch && _score > bestMatch.score){
        bestMatch.score = _score;
        bestMatch.queriedTokenIndex = queriedTokenIndex;
        bestMatch.matchIndices = _searchResult.matchedIndices;
      }

      return bestMatch;
    }, { score: 0, queriedTokenIndex: null, matchIndices: [] })
  });

  const _queriedTokensWithMatchIndices = _queriedTokens.map((queriedToken, index) => {
    return [
      queriedToken ,
      _queryTokensMatches.
        filter((match) => match.queriedTokenIndex === index).
        map(_.property("matchIndices")).
        pwPipe(_.flatten).
        map((indices) => _.range(indices[0], indices[1] + 1)).
        pwPipe(_.flatten).
        pwPipe(_.uniq).
        sort()
    ];
  });

  return {
    queryScore: queryScore(
      _queryTokensMatches.map(_.property("score")),
      _queryTokensMatches.map(_.property("queriedTokenIndex")).pwPipe(_.uniq).length,
      _queriedTokens.length
    ),
    queriedScore: queriedScore(
      _queryTokensMatches.map(_.property("queriedTokenIndex")).pwPipe(_.uniq).length,
      _queriedTokens.length
    ),
    queriedTokensWithMatchIndices: _queriedTokensWithMatchIndices
  };
}

const queriedScore = (matchedQueriedTokensCount, queriedTokensCount) => {
  return matchedQueriedTokensCount / queriedTokensCount;
}

const queryScore = (queryTokensScores, matchedQueriedTokensCount, queriedTokensCount) => {
  if (queryTokensScores.some((val) => val === 0)){

    // All 'query' tokens must match, or else 'queried' isn't a match
    return 0;
  }
  else {
    return (_.sum(queryTokensScores)/queryTokensScores.length);
  }
};

export default scoreString;
