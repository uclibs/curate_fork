//This is used to display and to hide hidden elements of work forms
var toggle = function() {
  $('.div-show').on('click', function(event) {
    event.preventDefault();
    if ($(this).text().substring(0,4) == "Show") {
      var replacement_text = $(this).text().replace(/^Show/,"Hide");
    } else {
      var replacement_text = $(this).text().replace(/^Hide/,"Show");
    }
    $(this).text(replacement_text);
    $(this).closest('div').find('.hidden-form-element').first().toggleClass('hidden');
  });
};

$(document).ready(toggle);
$(document).on('page:load', toggle);
