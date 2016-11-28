var data_table = $('table#estados_table');
initDataTable(data_table);

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
			var new_row = jqXHR.responseJSON.estado_obj;
			var last_index = data_table.DataTable().rows().data().length;
			data_table.DataTable().row.add([
				last_index + 1,
				new_row.nombre_estado,
				new_row.notificar ? "Si" : "No"
			]).draw(false);
			updateRowIndexes();
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

  function updateRowIndexes()
  {
  	data_table.DataTable().rows().every( function ( rowIdx, tableLoop, rowLoop ) {
			var d = this.data();
			d[0] = rowIdx + 1;
  	} );
  	data_table.DataTable().draw(false);
  }
});