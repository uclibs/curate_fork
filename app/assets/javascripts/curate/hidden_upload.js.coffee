$(document).on 'ready page:load', ->

  $realInputField = $('.control-group.file.optional input')

  # drop filename or file count (if > 1) in the display field
  $realInputField.change ->
    
    fileCount = @.files.length

    $('#file-display').val if (fileCount > 1) then (fileCount + " files") else $(@).val().replace(/^.*[\\\/]/, '')

  # trigger the real input field click to bring up the file selection dialog
  $('#upload-btn').click ->
    $realInputField.click()
