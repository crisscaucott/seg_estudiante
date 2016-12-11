var riesgoso_fields = $('div#riesgoso_fields').html();
$('div#datetimepicker1').datetimepicker({format: 'DD/MM/YYYY'});

$( "form#ficha_form" ).submit(function( event ) {
	event.preventDefault();
	data = $(event.target).serialize();
	btn = $(event.target).find('input[type=submit]');
	btn_text = btn.val();
  var noti_params = {msg: null, type: null};

	$.ajax({
		url: event.target.action,
		data: data,
		method: event.target.method,
		beforeSend: function()
		{
			btn.val('Guardando...');
			btn.toggleClass('disabled');
      showNotification({msg: "Guardando ficha del estudiante...", type: 'info', closeAll: true});
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
});

// Cada vez que se cambia una opcion en el combo de estados de desercion.
$("select#ficha_estudiante_estado_desercion_id").on('change', function(event){
  var is_riesgoso = $("option:selected", this).data('riesgoso');

  if (is_riesgoso) {
    $('div#riesgoso_fields').html(riesgoso_fields);
  }else{
    $('div#riesgoso_fields').empty();
  }
});