$('.checkable').live('change', function() {
  	$.ajax({
	    url: $(this).data('href'),
	    type: 'POST',
	    dataType: 'html',
	    success: function(data, textStatus, jqXHR) {
	      // Do something here like set a flash msg
	    }
	  });
});

$(document).ready(function() {
    $(':checkbox').iphoneStyle();

	$("#slide-toggle").click(function () {
		$('#slidefield').slideToggle('fast');
		$('#input_field').focus()
		return false;
    });
});