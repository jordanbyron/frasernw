const scoreStrings = (string1, string2) => {
  if (string1.trim() == "" || string2.trim() == "")
  {
    return 0.0;
  }
  else
  {
    var string1Words = string1.trim().toLowerCase().split(' ');
    var string2Words = string2.trim().toLowerCase().split(' ');

    var string1WordScores = string1Words.map((string1Word, string1WordIndex) => {
      var scoresAgainstString2Words = string2Words.map((string2Word, string2WordIndex) => {
        if (string1Word === string2Word) {
          return 1.0;
        }
        else {
          return fuzzilyScoreWords({
            word1: string1Word,
            word2: string2Word,
            word1Index: string1WordIndex,
            word2Index: string2WordIndex,
          })
        }
      })

      return Math.max(...scoresAgainstString2Words);
    })

    return (_.sum(string1WordScores) / string1WordScores.length);
  }
}

const fuzzilyScoreWords = ({
  word1,
  word2,
  word1Index,
  word2Index,
  fragment1StartIndex = 0,
  fragment2StartIndex = 0,
  matchesCount = 0,
  startOfWordMatchesCount = 0,
  errorFactor = 1,
  basicScore = 0,
  bonuses = 0
}) => {
  if ((fragment1StartIndex + 1) === word1.length){
    if (matchesCount !== 0)
    {
      // score for combination of word1, currentString2Word
      return ((basicScore - ((matchesCount - startOfWordMatchesCount) * 0.1)) / errorFactor) + bonuses;
    }
    else
    {
      return 0.0;
    }
  }
  else {
    var fragment1 = word1.substring(fragment1StartIndex, word1.length);
    var fragment2 = word2.substring(fragment2StartIndex, word2.length);

    var matchedFragmentLength = 0;
    var fragment2MatchIndex;

    for (var attemptingMatchLength = 1; attemptingMatchLength <= fragment1.length; attemptingMatchLength++)
    {
      fragment2MatchIndex = fragment2.indexOf(
        word1.substring(0, attemptingMatchLength)
      );

      if (fragment2MatchIndex && fragment2MatchIndex !== -1)
      {
        matchedFragmentLength = attemptingMatchLength;
      }
    }

    if (matchedFragmentLength > 0){
      return fuzzilyScoreWords({
        word1: word1,
        word2: word2,
        word1Index: word1Index,
        word2Index: word2Index,
        fragment1StartIndex: (fragment1StartIndex + 1),
        fragment2StartIndex: (fragment2StartIndex + matchedFragmentLength),
        matchesCount: (matchesCount + 1),
        startOfWordMatchesCount: (fragment2MatchIndex === 0 ? (startOfWordMatchesCount + 1) : startOfWordMatchesCount),
        errorFactor: errorFactor,
        basicScore: (basicScore + (matchedFragmentLength / Math.max(word1.length, word2.length))),
        bonuses: bonuses + calculateBonuses(matchedFragmentLength, fragment1StartIndex, fragment2MatchIndex, word1Index, word2Index)
      })
    }
    else {
      return fuzzilyScoreWords({
        word1: word1,
        word2: word2,
        word1Index: word1Index,
        word2Index: word2Index,
        fragment1StartIndex: (fragment1StartIndex + 1),
        fragment2StartIndex: (fragment2StartIndex + matchedFragmentLength),
        matchesCount: matchesCount,
        startOfWordMatchesCount: startOfWordMatchesCount,
        errorFactor: (matchedFragmentLength > 0 ? errorFactor : (errorFactor + 1 - FUZZINESS)),
        basicScore: basicScore,
        bonuses: bonuses
      })
    }
  }
}

const FUZZINESS = 0.5;

const calculateBonuses = (
  matchedFragmentLength,
  fragment1StartIndex,
  fragment2MatchIndex,
  word1Index,
  word2Index
) => {
  var bonuses = 0.0;

  if ((matchedFragmentLength >= 2) && fragment1StartIndex === 0 && fragment2MatchIndex === 0)
  {
    //matching the start of a search term to the start of a term
    bonuses += 0.1;

    if ((word1Index === 0) && (word2Index === 0))
    {
      //matched the start of our search to the start of the result
      bonuses += 0.2;
    }
  }

  return bonuses;
}

export default scoreStrings;
