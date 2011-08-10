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
	
	$('#listSubmit').click(function() {
		var vals = [];
		$(".checklist:checked").each(function(index, value){
		    vals[index] = value.value;
		});
		var list_data = "contacts=" + vals.join(',');
		//alert(data);
		$.post('/contacts', list_data);
		return false;
	});

	$("#slide-toggle").click(function () {
		$('#slidefield').slideToggle('fast');
		$('#input_field').focus()
		return false;
    });

	setTimeout(function() {
		$('#flash').slideUp('medium');
	}, 5000);
});