import BitapSearcher from "utils/bitap_searcher";

const BitapOptions = {
  threshold: 0.25,
  distance: 5
};

const scoreString = (query, queried) => {
  const _queryTokens = query.split(/\s+/g)
  const _queriedTokens = queried.split(/\s+/g)

  // we need to know which terms in 'queried' we matched for calculating the bonus score
  let _matchedQueriedTokenIndices = [];
  // we also need to know which 'query' tokens matched which 'queried' tokens, so we
  // can highlight 'queried' later
  let _queriedTokensWithMatchedQueryTokens = _queriedTokens.map((queriedToken) => {
    return [ queriedToken , []];
  });

  const _queryTokensMatches = _queryTokens.map((queryToken) => {
    return _queriedTokens.
      reduce((bestMatch, queriedToken, queriedTokenIndex) => {

      const _searchResult= new BitapSearcher(queryToken, BitapOptions).search(queriedToken)
      const _score = (1 - _searchResult.score);

      if (_searchResult.isMatch && _score > bestMatch.score){
        bestMatch.score = _score;
        bestMatch.queriedTokenIndex = queriedTokenIndex;
        bestMatch.matchIndices = _searchResult.matchedIndices;
      }

      return bestMatch;
    }, { score: 0, queriedTokenIndex: null, matchIndices: [] })
  });

  // if(_.every(_queryTokensMatches, (match) => match.score > 0)){
  //   console.log(_queryTokensMatches);
  // }

  const _queriedTokensWithMatchIndices = _queriedTokens.map((queriedToken, index) => {
    return [
      queriedToken ,
      _queryTokensMatches.
        filter((match) => match.queriedTokenIndex === index).
        map(_.property("matchIndices")).
        pwPipe(_.flatten).
        map((indices) => _.range(indices[0], (indices[0] + indices[1] + 1))).
        pwPipe(_.flatten).
        pwPipe(_.uniq).
        sort()
    ];
  });

  return {
    score: overallScore(
      _queryTokensMatches.map(_.property("score")),
      _queryTokensMatches.map(_.property("queriedTokenIndex")).pwPipe(_.uniq).length,
      _queriedTokens.length
    ),
    queriedTokensWithMatchIndices: _queriedTokensWithMatchIndices
  };
}

const overallScore = (queryTokensScores, matchedQueriedTokensCount, queriedTokensCount) => {
  if (queryTokensScores.some((val) => val === 0)){

    // All 'query' tokens must match, or else 'queried' isn't a match
    return 0;
  }
  else {
    const _averageQueryTokenScore = (_.sum(queryTokensScores)/queryTokensScores.length)

    // Bonus based on the proportion of 'queried' matched should act as a tiebreaker
    // in case the same matches crop up in multiple 'queried's.
    // Specifically thinking of areas of practice here:
    // If we search 'knee', we want 'knee' to be first, not 'knee arthroscopy',
    // for instance.
    const _queriedTokensBonus = 0.0001 * (matchedQueriedTokensCount / queriedTokensCount);

    return _averageQueryTokenScore + _queriedTokensBonus;
  }
};

export default scoreString;
