// Evento de enviar formulario
$( "form#sign_up_user" ).submit(function( event ) {
	// Se evita que se recargue la pagina al enviar el formulario
	event.preventDefault();
	var data;
	data = $(event.target).serialize();

	var n = noty({text: 'noty - a jquery notification library!'});

	// $.ajax({
	// 	url: event.target.action,
	// 	data: data,
	// 	method: event.target.method
	// }).done(function(data, textStatus, jqXHR) {
	// 		console.log("done");
	// 		console.log(data);
	// 		console.log(textStatus);
	// 		console.log(jqXHR);

 //  }).fail(function(jqXHR, textStatus, errorThrown) {
	// 		console.log("fail");
	// 		console.log(jqXHR);
	// 		console.log(textStatus);
	// 		console.log(errorThrown);
 //  }).always(function(data, textStatus, errorThrown) {
 //  		console.log("always");
 //  		console.log(data);
 //  		console.log(textStatus);
 //  		console.log(errorThrown);
 //  });

});