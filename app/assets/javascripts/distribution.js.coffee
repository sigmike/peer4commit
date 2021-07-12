$(document).on "turbolinks:load", ->
  root = $("#add-recipient-panels")
  recipients = $("#recipients")

  root.find("form").submit ->
    form = $(this)
    form.find(".alert").remove()
    panel = form.closest(".panel")
    $.ajax
      type: 'GET'
      url: form.attr("action")
      data: form.serialize()
      success: (data) ->
        if data.error
          form.append($("<div>").addClass("alert alert-danger").text(data.error))
        else
          recipients.append(data.result)
          form[0].reset()
        false
      error: ->
        form.append($("<div>").addClass("alert alert-danger").text("An error occurred."))
    false

  $(".commit-autocomplete[data-project-id]").each ->
    input = $(this)
    projectId = input.data("project-id")
    source = new Bloodhound
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("sha")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: "/projects/#{projectId}/commit_suggestions.json?query=%QUERY"

    source.initialize()

    input.typeahead {minLength: 2, highlight: true},
      displayKey: "sha"
      source: source.ttAdapter()
      templates:
        suggestion: (object) ->
          object.description

    if input.data("submit")
      input.bind "typeahead:selected", ->
        setTimeout ->
          input.closest("form").submit()
          input.typeahead('val', '')
        , 100

  $(".github-user-autocomplete[data-project-id]").each ->
    input = $(this)
    projectId = input.data("project-id")
    source = new Bloodhound
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("login")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: "/projects/#{projectId}/github_user_suggestions.json?query=%QUERY"

    source.initialize()

    input.typeahead {minLength: 1, highlight: true},
      displayKey: "login"
      source: source.ttAdapter()
      templates:
        suggestion: (object) ->
          object.description

    if input.data("submit")
      input.bind "typeahead:selected", ->
        setTimeout ->
          input.closest("form").submit()
          input.typeahead('val', '')
        , 100

  $(".user-autocomplete").each ->
    input = $(this)
    source = new Bloodhound
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("identifier")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: "/users/suggestions.json?query=%QUERY"

    source.initialize()

    input.typeahead {minLength: 1, highlight: true},
      displayKey: "identifier"
      source: source.ttAdapter()
      templates:
        suggestion: (object) ->
          object.description

    if input.data("submit")
      input.bind "typeahead:selected", ->
        setTimeout ->
          input.closest("form").submit()
          input.typeahead('val', '')
        , 100
