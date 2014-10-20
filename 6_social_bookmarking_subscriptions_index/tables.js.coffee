ready = ->

	$('th > .asc').append(" <i class='fi-arrow-up'></i>")
	$('th > .desc').append(" <i class='fi-arrow-down'</i>")

$(document).ready(ready)
$(document).on('page:load', ready)