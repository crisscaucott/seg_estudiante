$('#datetimepicker1').datetimepicker({format: 'DD/MM/YYYY'});
$( "form#config_alertas_form" ).submit(function( event ) {
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
      showNotification({msg: "Guardando configuración...", type: 'info', closeAll: true});
		}
	}).done(function(data, textStatus, jqXHR) {
      noti_params.msg = data.msg;
      noti_params.type = data.type;
      document.getElementById('config_table').innerHTML = data.config_table;

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