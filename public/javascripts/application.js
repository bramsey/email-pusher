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

$('#flash').live('click', function() {
  	$('#flash').slideUp('medium');
});

$(document).ready(function() {
    $('.checkable').iphoneStyle();
	$('.checklist').shiftcheckbox();
	
	$('#checkAll').click(
	   function()
	   {
	      $(".checklist").attr('checked', $('#checkAll').is(':checked'));   
	   }
	)

	$("#slide-toggle").click(function () {
		$('#slidefield').slideToggle('fast');
		$('#input_field').focus()
		return false;
    });

	setTimeout(function() {
		$('#flash').slideUp('medium');
	}, 5000);
});