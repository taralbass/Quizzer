/* DO NOT MODIFY. This file was compiled Tue, 09 Aug 2011 04:00:09 GMT from
 * /home/tbass/github/quizzer/app/coffeescripts/evaluate.coffee
 */

(function() {
  jQuery(function() {
    window.questionIndex = 1;
    window.questionIds = jQuery.parseJSON($('#evaluation_in_progress').attr('data-question-ids'));
    $('#evaluation_in_progress .posed_question').displayNextQuestion();
    return $('body').delegate('#evaluation_in_progress .result_actions input[type="submit"]', 'click', function() {
      var result;
      result = $(this).attr('data-result');
      if (typeof result !== 'undefined' && result !== false) {
        $.ajax({
          type: 'PUT',
          url: $(this).closest('.result_actions').attr('data-action'),
          data: {
            'evaluation': {
              'results_attributes': [
                {
                  'question_id': window.currentQuestionId,
                  'result': result
                }
              ]
            }
          }
        });
      }
      return $('#evaluation_in_progress').find('.result').html("").end().find('.posed_question').displayNextQuestion();
    });
  });
  jQuery.fn.displayNextQuestion = function() {
    if (window.questionIds.length > 0) {
      window.currentQuestionId = window.questionIds.shift();
      return $.ajax({
        url: $(this).attr('data-action'),
        data: "question_id=" + window.currentQuestionId,
        error: function() {
          return alert("An error has occured. Please refresh the page and start over.");
        }
      });
    } else {
      return $('.evaluation_complete form').submit();
    }
  };
}).call(this);
