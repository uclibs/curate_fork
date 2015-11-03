// This is a manifest file that'll be compiled into curate.js, which will include all the files
// listed below.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//
//= require jquery-ui-1.9.2/jquery.ui.widget
//= require jquery-ui-1.9.2/jquery.ui.core
//= require jquery-ui-1.9.2/jquery.ui.menu
//= require jquery-ui-1.9.2/jquery.ui.position
//= require jquery-ui-1.9.2/jquery.ui.autocomplete
//
//= require blacklight/blacklight
//
//= require bootstrap-dropdown
//= require bootstrap-button
//= require bootstrap-collapse
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-datepicker/core
//
//= require manage_repeating_fields
//= require toggle_details
//= require toggle_div
//= require help_modal
//= require jquery.tokeninput
//= require curate/select_works
//= require curate/link_users
//= require curate/link_groups
//= require curate/proxy_rights
//= require curate/facet_mine
//= require curate/accept_contributor_agreement
//= require curate/proxy_submission
//= require handlebars
//= require browse_everything
//= require curate/browse_everything_implement
//= require curate/validate_doi
//= require curate/hidden_upload

// Initialize plugins and Bootstrap dropdowns on jQuery's ready event as well as
// Turbolinks's page change event.
Blacklight.onLoad(function() {
  $('abbr').tooltip();

  $('body').on('keypress', '.multi-text-field', function(event) {
    var $activeField = $(event.target).parents('.field-wrapper'),
        $activeFieldControls = $activeField.children('.field-controls'),
        $addControl=$activeFieldControls.children('.add'),
        $removeControl=$activeFieldControls.children('.remove');
    if (event.keyCode == 13) {
      event.preventDefault();
      $addControl.click()
      $removeControl.click()
    }
  });
  $('.multi_value.control-group').manage_fields();
  $('.link-users').linkUsers();
  $('.link-groups').linkGroups();
  $('.proxy-rights').proxyRights();


  $('#set-access-controls .datepicker').datepicker({
    format: 'yyyy-mm-dd',
    startDate: '+1d'
  });

  $('.remove-member').on('ajax:success', function(){window.location.href = window.location.href});

  $("[data-toggle='dropdown']").dropdown();

});

