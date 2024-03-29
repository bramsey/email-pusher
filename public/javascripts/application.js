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

$('#container').delegate('#slide-toggle', 'click', function () {
	$('#slidefield').slideToggle('fast');
	$('#input_field').focus()
	return false;
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

	setTimeout(function() {
		$('#flash').slideUp('medium');
	}, 5000);
	
	var $top1= $('#header').offset().top + 20; //add additional necessary offset for Webkit  
	$(window).scroll(function()  
	{  
	    if ($(window).scrollTop())  
	    {  
	     $('#header').addClass('floating');  
	    }  
	    else  
	    {  
	     $('#header').removeClass('floating');  
	     }  
	});
});