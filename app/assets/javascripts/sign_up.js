// Evento de enviar formulario
$( "form#sign_up_user" ).submit(function( event ) {
	// Se evita que se recargue la pagina al enviar el formulario
	event.preventDefault();
	var data;
	data = $(event.target).serialize();

	// showNoty();
	$.ajax({
		url: event.target.action,
		data: data,
		method: event.target.method
	}).done(function(data, textStatus, jqXHR) {
			console.log("done");
			console.log(data);
			console.log(textStatus);
			console.log(jqXHR);

  }).fail(function(jqXHR, textStatus, errorThrown) {
			console.log("fail");
			showNoty({text: jqXHR.responseJSON.errors})
			console.log(jqXHR);
			console.log(textStatus);
			console.log(errorThrown);
  }).always(function(data, textStatus, errorThrown) {
  		console.log("always");
  		console.log(data);
  		console.log(textStatus);
  		console.log(errorThrown);
  });

});