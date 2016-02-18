module SentenceHelper
  def normal_weight_sentence_connectors
    {
      words_connector: '<span style="font-weight:normal;">, </span>'.html_safe,
      two_words_connector: '<span style="font-weight:normal;"> and </span>'.html_safe,
      last_word_connector: '<span style="font-weight:normal;">, and </span>'.html_safe
    }
  end
end
