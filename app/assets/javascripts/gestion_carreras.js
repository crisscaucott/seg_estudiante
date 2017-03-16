// Inicializar variables para tabla de carreras.
var data_table_carreras = $('table#carreras_table');
var datatable_options_carreras = {
    dom: 'tip',
    columns: [
      {"data": "num"}, 
      {"data": "nombre"}, 
      {"data": "duracion"},
      {"data": "codigo"},
      {"data": "asignaturas"},
      {"data": "actions"},
    ],
  }
initDataTable(data_table_carreras, datatable_options_carreras);

// Inicializar variables para tabla de asignaturas.
var data_table_asignaturas = $('table#asignaturas_table');
var datatable_options_asignaturas = {
    dom: 'tip',
    columns: [
      {"data": "num"}, 
      {"data": "nombre"}, 
      {"data": "codigo"},
      {"data": "creditos"},
      {"data": "actions"},
    ],
  }  


// Evento de click en el boton "editar" de la tabla de carreras.
$('div#carreras_container').on('click', 'button.edit_btn', function(event){
  var tr = $(this).parents('tr');
  var trs = $(this).parents('tbody').children();
  var submit_btn = $("form#carreras_form").find('input[type=submit]');

  // Dejar activa la fila que se edita.

  for(var i = 0; i < trs.length; i++){
    if (tr[0].rowIndex === trs[i].rowIndex) // Fila de la tabla donde se va a editar.
    {
      // Quitar la fila selecionada para eliminar.
      $(trs[i]).removeClass('danger');
      $(trs[i]).find('input.row_delete').val(0);

      $(trs[i]).toggleClass('info');

      if ($(trs[i]).hasClass('info')){
        $(trs[i]).find('span').addClass('hidden');
        $(trs[i]).find('.form-control').removeClass('hidden');
        $(trs[i]).find('input.row_edited').val(1);

        // Habilitar el boton submit de finalizar
        submit_btn.attr('disabled', false);

      }else{
        $(trs[i]).find('span').removeClass('hidden');
        $(trs[i]).find('.form-control').addClass('hidden');
        $(trs[i]).find('input.row_edited').val(0);

        // Desabilitar el boton submit de finalizar.
        submit_btn.attr('disabled', true);
      }
      
    }else{
      $(trs[i]).removeClass('info');
      $(trs[i]).find('span').removeClass('hidden');
      $(trs[i]).find('.form-control').addClass('hidden');
      $(trs[i]).find('input.row_edited').val(0);
    }
  }
});

// Evento de click en el boton "Eliminar" de la tabla de carreras.
$('div#carreras_container').on('click', 'button.delete_btn', function(event){
  var tr = $(this).parents('tr');
  var trs = $(this).parents('tbody').children();
  var submit_btn = $("form#carreras_form").find('input[type=submit]');
  
  for(var i = 0; i < trs.length; i++){
    if (tr[0].rowIndex === trs[i].rowIndex){ // Fila de la tabla donde se va a editar.
      $(trs[i]).removeClass('info');
      $(trs[i]).toggleClass('danger');

      if ($(trs[i]).hasClass('danger')){
        $(trs[i]).find('span').removeClass('hidden');
        $(trs[i]).find('.form-control').addClass('hidden');
        $(trs[i]).find('input.row_edited').val(0);
        $(trs[i]).find('input.row_delete').val(1);

        // Habilitar el boton submit de finalizar
        submit_btn.attr('disabled', false);

      }else{
        $(trs[i]).find('span').removeClass('hidden');
        $(trs[i]).find('.form-control').addClass('hidden');
        $(trs[i]).find('input.row_edited').val(0);
        $(trs[i]).find('input.row_delete').val(0);

        // Desabilitar el boton submit de finalizar.
        submit_btn.attr('disabled', true);
      }

    }else{
      // Todas las filas que no sea la seleccionada.
      $(trs[i]).removeClass('danger');
      $(trs[i]).find('input.row_delete').val(0);
      $(trs[i]).find('input.row_edited').val(0);

    }
  }
});

// Enviar formulario con los cambios de la tabla de carreras (editar o eliminar)
$('div#carreras_container').on('submit', 'form#carreras_form', function(event){
	event.preventDefault();
  var trs = data_table_carreras.find('tbody').children(), tr = null, hidden_upd = null, hidden_del = null, data = null, noti_params = {msg: null, type: null}, btn = $(this).find('input[type=submit]'), btn_text = btn.val();

  for (var i = 0; i < trs.length; i++)
  {
    hidden_upd = $(trs[i]).find('input.row_edited').val();
    hidden_del = $(trs[i]).find('input.row_delete').val();
    
    if (hidden_upd == 1 || hidden_del == 1){
      data = $(trs[i]).find('input').serialize();
      tr = $(trs[i]);
      break;
    }
  }

  if (data !== null) {
  	$.ajax({
  	  url: event.target.action,
  	  data: data,
  	  method: event.target.method,
  	  beforeSend: function()
  	  {
  	    btn.val('Guardando...');
  	    btn.toggleClass('disabled');
  	    showNotification({msg: "Guardando cambios...", type: 'info', closeAll: true});

  	  }
  	}).done(function(data, textStatus, jqXHR) {
  	    noti_params.msg = data.msg;
  	    noti_params.type = data.type;

  	    data_table_carreras.DataTable().clear();
  	    $('div#carreras_container').html(data.table);
  	    data_table_carreras.DataTable().draw();

  	    data_table_carreras = $('table#carreras_table');
  	    initDataTable(data_table_carreras, datatable_options_carreras);

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
  }

});


// Cada vez que se cambia de opcion del combo de escuelas.
$("select#escuela_escuela").on('change', function(event){
	var escuela_id = $("option:selected", this).val();
	var form_element = $(this).parents('form');
	var noti_params = {msg: null, type: null};

	if (escuela_id) {
		$.ajax({
			url: form_element[0].action,
			data: form_element.serialize(),
			method: form_element[0].method,
			beforeSend: function()
			{
				// btn.val('Registrando...');
				// btn.toggleClass('disabled');
	    	showNotification({msg: "Obteniendo carreras de la escuela seleccionada...", type: 'info', closeAll: true});
			}
		}).done(function(data, textStatus, jqXHR) {
				noti_params.msg = data.msg;
		    noti_params.type = data.type;

				data_table_carreras.DataTable().clear();
				$('div#carreras_container').html(data.table);
				data_table_carreras.DataTable().draw();

				data_table_carreras = $('table#carreras_table');
	      initDataTable(data_table_carreras, datatable_options_carreras);

	  }).fail(function(jqXHR, textStatus, errorThrown) {
	  		noti_params.msg = errorThrown;
	  		noti_params.type = 'danger';

	  		if (jqXHR.responseJSON !== undefined)
	  		{
	  		  noti_params.msg = jqXHR.responseJSON.msg;
	  		  noti_params.type = jqXHR.responseJSON.type;
	  		}

	  }).always(function(data, textStatus, errorThrown) {
	  		// btn.toggleClass('disabled');
	  		// btn.val(btn_text);
	    	showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
	  });	
	}
});

$('div#carreras_container').on('click', 'button.asignaturas_btn', function(event){
  var noti_params = {msg: null, type: 'info'};
	var data = {id: $(this).parents('tr').data('carrera-id')}

	$.ajax({
		url: '/admini/carreras/gestion/asignaturas_by_carrera',
		data: data,
		method: "post",
		beforeSend: function()
		{
			// btn.val('Registrando...');
			// btn.toggleClass('disabled');
    	showNotification({msg: "Obteniendo asignaturas de la carrera seleccionada...", type: 'info', closeAll: true});
		}
	}).done(function(data, textStatus, jqXHR) {
			noti_params.msg = data.msg;
	    noti_params.type = data.type;
      
			bootbox.alert({
		    size: 'large',
		    title: "Asignaturas de '" + data.carrera + "'",
		    message: data.table
		  });
			data_table_asignaturas.DataTable().clear();
			data_table_asignaturas.DataTable().draw();

			data_table_asignaturas = $('table#asignaturas_table');
      initDataTable(data_table_asignaturas, datatable_options_asignaturas);

			enableEventListener();

  }).fail(function(jqXHR, textStatus, errorThrown) {
  		noti_params.msg = errorThrown;
  		noti_params.type = 'danger';

  		if (jqXHR.responseJSON !== undefined)
  		{
  		  noti_params.msg = jqXHR.responseJSON.msg;
  		  noti_params.type = jqXHR.responseJSON.type;
  		}

  }).always(function(data, textStatus, errorThrown) {
  		// btn.toggleClass('disabled');
  		// btn.val(btn_text);
    	showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
  });	
});

// Agregar los listener a los botones que aparecen en la ventana emergente con las asignaturas.
function enableEventListener(){
	// Evento de click en el boton "editar" de la tabla de asignaturas.
	$('div.bootbox').on('click', 'button.edit_btn', function(event){
		var tr = $(this).parents('tr');
		var trs = $(this).parents('tbody').children();
		var submit_btn = $("form#asignaturas_form").find('input[type=submit]');

		// Dejar activa la fila que se edita.
		for(var i = 0; i < trs.length; i++){
		  if (tr[0].rowIndex === trs[i].rowIndex) // Fila de la tabla donde se va a editar.
		  {
		    // Quitar la fila selecionada para eliminar.
		    $(trs[i]).removeClass('danger');
		    $(trs[i]).find('input.row_delete').val(0);

		    $(trs[i]).toggleClass('info');

		    if ($(trs[i]).hasClass('info')){
		      $(trs[i]).find('span').addClass('hidden');
		      $(trs[i]).find('.form-control').removeClass('hidden');
		      $(trs[i]).find('input.row_edited').val(1);

		      // Habilitar el boton submit de finalizar
		      submit_btn.attr('disabled', false);

		    }else{
		      $(trs[i]).find('span').removeClass('hidden');
		      $(trs[i]).find('.form-control').addClass('hidden');
		      $(trs[i]).find('input.row_edited').val(0);

		      // Desabilitar el boton submit de finalizar.
		      submit_btn.attr('disabled', true);
		    }
		    
		  }else{
		    $(trs[i]).removeClass('info');
		    $(trs[i]).find('span').removeClass('hidden');
		    $(trs[i]).find('.form-control').addClass('hidden');
		    $(trs[i]).find('input.row_edited').val(0);
		  }
		}

	});

	// Evento de click en el boton "Eliminar" de la tabla de asignaturas.
	$('div.bootbox').on('click', 'button.delete_btn', function(event){
	  var tr = $(this).parents('tr');
	  var trs = $(this).parents('tbody').children();
	  var submit_btn = $("form#asignaturas_form").find('input[type=submit]');
	  
	  for(var i = 0; i < trs.length; i++){
	    if (tr[0].rowIndex === trs[i].rowIndex){ // Fila de la tabla donde se va a editar.
	      $(trs[i]).removeClass('info');
	      $(trs[i]).toggleClass('danger');

	      if ($(trs[i]).hasClass('danger')){
	        $(trs[i]).find('span').removeClass('hidden');
	        $(trs[i]).find('.form-control').addClass('hidden');
	        $(trs[i]).find('input.row_edited').val(0);
	        $(trs[i]).find('input.row_delete').val(1);

	        // Habilitar el boton submit de finalizar
	        submit_btn.attr('disabled', false);

	      }else{
	        $(trs[i]).find('span').removeClass('hidden');
	        $(trs[i]).find('.form-control').addClass('hidden');
	        $(trs[i]).find('input.row_edited').val(0);
	        $(trs[i]).find('input.row_delete').val(0);

	        // Desabilitar el boton submit de finalizar.
	        submit_btn.attr('disabled', true);
	      }

	    }else{
	      // Todas las filas que no sea la seleccionada.
	      $(trs[i]).removeClass('danger');
	      $(trs[i]).find('input.row_delete').val(0);
	      $(trs[i]).find('input.row_edited').val(0);

	    }
	  }
	});

	// Enviar formulario con los cambios de la tabla de asignaturas (editar o eliminar)
	$('div.bootbox').on('submit', 'form#asignaturas_form', function(event){
		event.preventDefault();
		var trs = data_table_asignaturas.find('tbody').children(), tr = null, hidden_upd = null, hidden_del = null, data = null, noti_params = {msg: null, type: null}, btn = $(this).find('input[type=submit]'), btn_text = btn.val();

		for (var i = 0; i < trs.length; i++)
		{
		  hidden_upd = $(trs[i]).find('input.row_edited').val();
		  hidden_del = $(trs[i]).find('input.row_delete').val();
		  
		  if (hidden_upd == 1 || hidden_del == 1){
		    data = $(trs[i]).find('input').serialize();
		    tr = $(trs[i]);
		    break;
		  }
		}

		if (data !== null) {
			$.ajax({
			  url: event.target.action,
			  data: data,
			  method: event.target.method,
			  beforeSend: function()
			  {
			    btn.val('Guardando...');
			    btn.toggleClass('disabled');
			    showNotification({msg: "Guardando cambios...", type: 'info', closeAll: true, important: true});

			  }
			}).done(function(data, textStatus, jqXHR) {
			    noti_params.msg = data.msg;
			    noti_params.type = data.type;

    			data_table_asignaturas.DataTable().clear();
			    $('div.bootbox-body').html(data.table);
    			data_table_asignaturas.DataTable().draw();

    			data_table_asignaturas = $('table#asignaturas_table');
          initDataTable(data_table_asignaturas, datatable_options_asignaturas);

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
			    showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true, important: true})
			});
		}

	});

}
