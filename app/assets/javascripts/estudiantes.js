var data_table = $('table#estudiantes_table');
var datatable_options = {
    dom: 'tip',
    columns: [
      {"data": "num"}, 
      {"data": "nombre"}, 
      {"data": "rut"},
      {"data": "anio_ingreso"},
      {"data": "carrera"},
      {"data": "estado_desercion"},
      {"data": "editar"},
    ],
  }

initDataTable(data_table, datatable_options);

$('div#estudiantes_container').on('click', 'button.edit_btn', function(event){
	var tr = $(this).parents('tr');
	var trs = $(this).parents('tbody').children();
	var hidden_element = tr.find('input[type=hidden].row_edited');

	if (hidden_element.val() == "1") {
		// Fila seleccionada para editar
		hidden_element.val(0);
		tr.removeClass('info');
		tr.find('span').removeClass('hidden');
		tr.find('select').addClass('hidden');

	}else if (hidden_element.val() == "0") {
		// Fila no seleccionada para editar
		hidden_element.val(1);
		tr.addClass('info');
		tr.find('span').addClass('hidden');
		tr.find('select').removeClass('hidden');

	}
	checkEstudiantesEdited(trs);
});

function checkEstudiantesEdited (rows) {
	var hidden_element, row_edited = false;
	for (var i = 0; i < rows.length; i++) {
		hidden_element = $(rows[i]).find('input[type=hidden].row_edited');
		if (hidden_element.val() == 1) {
			row_edited = true;
			break;
		}
	}

	// Si alguna de las filas de la tabla se edito, se habilita el boton submit.
	if (row_edited) {
		$('form#estudiantes_form input[type=submit]').prop('disabled', false);
	}else{
		$('form#estudiantes_form input[type=submit]').prop('disabled', true);
	}
}

$('div#estudiantes_container').on('submit', 'form#estudiantes_form', function(event){
	event.preventDefault();
	var rows = $(event.target).find('tbody').children();
	var rows_to_upd = [];
	var hidden_element;
	var btn = $(event.target).find('input[type=submit]'), btn_text = btn.val();
	var noti_params = {msg: null, type: null};

	$.ajax({
	  url: event.target.action,
	  data: $(event.target).serializeArray(),
	  method: event.target.method,
	  beforeSend: function()
	  {
	    btn.val('Actualizando...');
	    btn.toggleClass('disabled');
	    showNotification({msg: "Actualizando estudiante...", type: 'info', closeAll: true});

	  }
	}).done(function(data, textStatus, jqXHR) {
	    noti_params.msg = data.msg;
	    noti_params.type = data.type;

	    data_table.DataTable().clear();
	    $('div#estudiantes_container').html(data.table);
	    data_table.DataTable().draw();

	    data_table = $('table#estudiantes_table');
	    initDataTable(data_table, datatable_options);

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