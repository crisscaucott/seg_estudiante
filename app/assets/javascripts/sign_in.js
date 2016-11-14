// Evento de enviar formulario
$( "form#sign_in_user" ).submit(function( event ) {
	// Se evita que se recargue la pagina al enviar el formulario
	event.preventDefault();
	var data;
	data = $(event.target).serialize();

	btn = $(event.target).find('input[type=submit]');
	btn_text = btn.val();

	$.ajax({
		url: event.target.action,
		data: data,
		method: event.target.method,
		beforeSend: function()
		{
			btn.val('Ingresando...');
			btn.toggleClass('disabled');
		}
	}).done(function(data, textStatus, jqXHR) {
			// console.log("done");
			// console.log(data);
			// console.log(textStatus);
			// console.log(jqXHR);

  }).fail(function(jqXHR, textStatus, errorThrown) {
			console.log("fail");
			showNotification({msg: jqXHR.responseText, type: 'danger'})

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