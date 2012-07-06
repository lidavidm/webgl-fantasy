#= require jquery

$(document).ready ->
  $("#list-delete").click ->
    $(".list-delete-checkbox").each ->
      if this.checked
        $.ajax
          type: 'DELETE'
          url: window.location.pathname + 'delete/' + $(this).attr('value')
          success: =>
            $(this).parent().parent().hide(500)