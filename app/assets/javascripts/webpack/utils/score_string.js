import * as FuzzAldrin from "fuzzaldrin";

const MinQueryTokenScore = 0.1;

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

  const _queryTokensScores = _queryTokens.map((queryToken) => {
    const _maxQueryTokenScore = _queriedTokens.
      reduce((currentMax, queriedToken, queriedTokenIndex) => {

      const _score = FuzzAldrin.score(queriedToken, queryToken)

      if (_score > currentMax.val){
        currentMax.val = _score;
        currentMax.queriedIndex = queriedTokenIndex;
      }

      return currentMax;
    }, { val: 0, queriedIndex: null })

    if (_maxQueryTokenScore.val >= MinQueryTokenScore) {

      _queriedTokensWithMatchedQueryTokens[_maxQueryTokenScore.queriedIndex][1].
        push(queryToken);
      _matchedQueriedTokenIndices.push(_maxQueryTokenScore.queriedIndex);

      return _maxQueryTokenScore;
    }
    else {

      // 'query' token didn't match
      return 0;
    }
  })

  return {
    queriedTokensWithMatchedQueryTokens: _queriedTokensWithMatchedQueryTokens,
    score: overallScore(
      _queryTokensScores,
      _.uniq(_matchedQueriedTokenIndices).length,
      _queriedTokens.length
    )
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
    const _queriedTokensBonus = 0.01 * (matchedQueriedTokensCount / queriedTokensCount);

    return _averageQueryTokenScore + _queriedTokensBonus;
  }
};

export default scoreString;
