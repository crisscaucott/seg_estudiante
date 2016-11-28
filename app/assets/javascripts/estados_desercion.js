$('#example').DataTable();

$( "form#estado_desercion_form" ).submit(function( event ) {
	event.preventDefault();
	data = $(event.target).serialize();
	btn = $(event.target).find('input[type=submit]');
	btn_text = btn.val();

	$.ajax({
		url: event.target.action,
		data: data,
		method: event.target.method,
		beforeSend: function()
		{
			btn.val('Agregando...');
			btn.toggleClass('disabled');
		}
	}).done(function(data, textStatus, jqXHR) {
			// console.log("done");
			// console.log(data);
			// console.log(textStatus);
			console.log(jqXHR);
			showNotification({msg: jqXHR.responseJSON.msg, type: 'success'})

  }).fail(function(jqXHR, textStatus, errorThrown) {
			console.log("fail");
			showNotification({msg: jqXHR.responseJSON.errors, type: 'danger'})

			// console.log(jqXHR);
			// console.log(textStatus);
			// console.log(errorThrown);
  }).always(function(data, textStatus, errorThrown) {
			btn.toggleClass('disabled');
  		btn.val(btn_text);
  		// console.log("always");
  		// console.log(data);
  		// console.log(textStatus);
  		// console.log(errorThrown);
  });
});