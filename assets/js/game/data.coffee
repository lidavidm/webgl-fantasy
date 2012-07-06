define ["use!use/jquery"], ($) ->
  loaded = new $.Deferred
  data =
    _loaded: loaded
    find: (props) ->
      for key of data
        record = data[key]
        matches = true
        for criterion of props
          if record[criterion] isnt props[criterion]
            matches = false
            break
        if matches
          return key
      return false

  $.getJSON "/gamedata/all.json", (allData) ->
    for id of allData
      data[id] = allData[id]
    loaded.resolve()

  return data