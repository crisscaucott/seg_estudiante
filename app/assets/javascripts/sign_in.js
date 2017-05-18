// Evento de enviar formulario
$( "form#sign_in_user" ).submit(function( event ) {
	// Se evita que se recargue la pagina al enviar el formulario
	event.preventDefault();
	var data, rut;
	data = $(event.target).serialize();
	rut = $(event.target).find("input[name='user[rut]']").val()
	btn = $(event.target).find('input[type=submit]');
	btn_text = btn.val();

	if (checkRut(rut)) 
	{
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
	}else
	{
		showNotification({msg: 'El rut ingresado no es válido.', type: 'danger'})
	}

});

// Formatear el campo del rut al escribir o pegar en el input.
$("input#user_rut").rut({
	formatOn: 'keyup change',
	validateOn: null // si no se quiere validar, pasar null
});
