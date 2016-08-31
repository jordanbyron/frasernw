const scoreStrings = (searchTerm, resultLabel) => {
  if (searchTerm.trim() == "" || resultLabel.trim() == "")
  {
    return 0.0;
  }
  else
  {
    var searchTermWords = searchTerm.trim().toLowerCase().split(' ');
    var resultLabelWords = resultLabel.trim().toLowerCase().split(' ');

    var searchTermWordScores = searchTermWords.
      map((searchTermWord, searchTermWordIndex) => {

      var scoresAgainstString2Words = resultLabelWords.
        map((resultLabelWord, resultLabelWordIndex) => {

        if (searchTermWord === resultLabelWord) {
          return 1.0;
        }
        else {
          return fuzzilyScoreWords({
            searchTermWord: searchTermWord,
            resultLabelWord: resultLabelWord,
            searchTermWordIndex: searchTermWordIndex,
            resultLabelWordIndex: resultLabelWordIndex,
          })
        }
      })

      return Math.max(...scoresAgainstString2Words);
    })

    return (_.sum(searchTermWordScores) / searchTermWordScores.length);
  }
}

const fuzzilyScoreWords = ({
  searchTermWord,
  resultLabelWord,
  searchTermWordIndex,
  resultLabelWordIndex,
  searchTermWordFragmentStartIndex = 0,
  resultLabelWordFragmentStartIndex = 0,
  matchesCount = 0,
  startOfWordMatchesCount = 0,
  errorFactor = 1,
  basicScore = 0,
  bonuses = 0
}) => {
  if (searchTermWordFragmentStartIndex === searchTermWord.length){
    if (matchesCount !== 0){
      return (
        ((basicScore - ((matchesCount - startOfWordMatchesCount) * 0.1)) /
          errorFactor)
        + bonuses
      )
    }
    else {
      return 0.0;
    }
  }
  else {
    var searchTermWordFragment = searchTermWord.substring(
      searchTermWordFragmentStartIndex,
      searchTermWord.length
    );
    var resultLabelWordFragment = resultLabelWord.substring(
      resultLabelWordFragmentStartIndex,
      resultLabelWord.length
    );

    var matchedFragmentLength = 0;
    var resultLabelWordFragmentMatchIndex = -1;

    for (var attemptingMatchLength = 1;
      attemptingMatchLength <= searchTermWordFragment.length;
      attemptingMatchLength++){

      resultLabelWordFragmentMatchIndex = resultLabelWordFragment.indexOf(
        searchTermWord.substring(0, attemptingMatchLength)
      );

      if (resultLabelWordFragmentMatchIndex === -1) {
        break;
      }
      else {
        matchedFragmentLength = attemptingMatchLength;
      }
    }

    if (matchedFragmentLength > 0){
      return fuzzilyScoreWords({
        searchTermWord: searchTermWord,
        resultLabelWord: resultLabelWord,
        searchTermWordIndex: searchTermWordIndex,
        resultLabelWordIndex: resultLabelWordIndex,
        searchTermWordFragmentStartIndex: (searchTermWordFragmentStartIndex +
          matchedFragmentLength),
        resultLabelWordFragmentStartIndex: (resultLabelWordFragmentStartIndex +
          resultLabelWordFragmentMatchIndex +
          matchedFragmentLength),
        matchesCount: (matchesCount + 1),
        startOfWordMatchesCount: (resultLabelWordFragmentMatchIndex === 0 ?
          (startOfWordMatchesCount + 1) :
          startOfWordMatchesCount),
        errorFactor: errorFactor,
        basicScore: (basicScore +
          (matchedFragmentLength /
            Math.max(searchTermWord.length, resultLabelWord.length))),
        bonuses: (bonuses +
          calculateBonuses(
            matchedFragmentLength,
            searchTermWordFragmentStartIndex,
            resultLabelWordFragmentMatchIndex,
            searchTermWordIndex,
            resultLabelWordIndex
          ))
      })
    }
    else {
      return fuzzilyScoreWords({
        searchTermWord: searchTermWord,
        resultLabelWord: resultLabelWord,
        searchTermWordIndex: searchTermWordIndex,
        resultLabelWordIndex: resultLabelWordIndex,
        searchTermWordFragmentStartIndex: (searchTermWordFragmentStartIndex + 1),
        resultLabelWordFragmentStartIndex: resultLabelWordFragmentStartIndex,
        matchesCount: matchesCount,
        startOfWordMatchesCount: startOfWordMatchesCount,
        errorFactor: (errorFactor + 1 - FUZZINESS),
        basicScore: basicScore,
        bonuses: bonuses
      })
    }
  }
}

const FUZZINESS = 0.5;

const calculateBonuses = (
  matchedFragmentLength,
  searchTermWordFragmentStartIndex,
  resultLabelWordFragmentMatchIndex,
  searchTermWordIndex,
  resultLabelWordIndex
) => {
  var bonuses = 0.0;

  if ((matchedFragmentLength >= 2) &&
    searchTermWordFragmentStartIndex === 0 &&
    resultLabelWordFragmentMatchIndex === 0){

    //matching the start of a search term to the start of a term
    bonuses += 0.1;

    if ((searchTermWordIndex === 0) && (resultLabelWordIndex === 0)){
      //matched the start of our search to the start of the result
      bonuses += 0.2;
    }
  }

  return bonuses;
}

export default scoreStrings;
