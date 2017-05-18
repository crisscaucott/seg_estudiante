var carrera_options = $('div#escuela_field').html();
$('div#escuela_field').empty();

// Evento de enviar formulario
$( "form#sign_up_user" ).submit(function( event ) {
	var data, btn;
	var noti_params = {msg: null, type: null};
	// Se evita que se recargue la pagina al enviar el formulario
	event.preventDefault();
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
				btn.val('Registrando...');
				btn.toggleClass('disabled');
	    	showNotification({msg: "Creando usuario...", type: 'info', closeAll: true});
			}
		}).done(function(data, textStatus, jqXHR) {
				noti_params.msg = data.msg;
		    noti_params.type = data.type;

	  }).fail(function(jqXHR, textStatus, errorThrown) {
	  		noti_params.msg = errorThrown;
	  		noti_params.type = 'danger';

	  		if (jqXHR.responseJSON !== undefined)
	  		{
	  		  noti_params.msg = jqXHR.responseJSON.msg;
	  		  noti_params.type = jqXHR.responseJSON.type;
	  		}

	  }).always(function(data, textStatus, errorThrown) {
	  		btn.toggleClass('disabled');
	  		btn.val(btn_text);
	    	showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
	  });		
	}else
	{
		showNotification({msg: 'El rut ingresado no es válido.', type: 'danger'})
	}

});

// Cada vez que se cambia una opcion en el combo de estados de desercion.
$("select#user_id_permission").on('change', function(event){
  var escuela_id = $("option:selected", this).text();

  if (escuela_id == 'Director') {
    $('div#escuela_field').html(carrera_options);
  }else{
    $('div#escuela_field').empty();
  }
});

// Formatear el campo del rut al escribir o pegar en el input.
$("input#user_rut").rut({
	formatOn: 'keyup change',
	validateOn: null // si no se quiere validar, pasar null
});