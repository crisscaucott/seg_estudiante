var data_table = $('table#users_table');
var datatable_options = {
    dom: 'tip',
    columns: [
      {"data": "num"}, 
      {"data": "name"}, 
      {"data": "last_name"},
      {"data": "email"},
      {"data": "rut"},
      {"data": "user_type"},
      {"data": "deleted"},
      {"data": "actions"},
    ],
  }

initDataTable(data_table, datatable_options);

// Evento de click en el boton "editar" de la tabla de usuarios.
$('div#table_container').on('click', 'button.edit_btn', function(event){
  var tr = $(this).parents('tr');
  var trs = $(this).parents('tbody').children();
  var submit_btn = $("form#user_form").find('input[type=submit]');

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

// Evento de click en el boton "Eliminar" de la tabla de usuarios.
$('div#table_container').on('click', 'button.delete_btn', function(event){
  var tr = $(this).parents('tr');
  var trs = $(this).parents('tbody').children();
  var submit_btn = $("form#user_form").find('input[type=submit]');
  
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

// Envio de formulario de edicion de usuarios de la tabla.
$('div#table_container').on('submit', 'form#user_form', function(event){
  event.preventDefault();
  var trs = data_table.find('tbody').children(), tr = null, hidden_upd = null, hidden_del = null, data = null, noti_params = {msg: null, type: null}, rut = null, btn = $(event.target).find('input[type=submit]'), btn_text = btn.val();

  for (var i = 0; i < trs.length; i++)
  {
    hidden_upd = $(trs[i]).find('input.row_edited').val();
    hidden_del = $(trs[i]).find('input.row_delete').val();
    
    if (hidden_upd == 1 || hidden_del == 1){
      data = $(trs[i]).find('input,select').serialize();
      rut = $(trs[i]).find('input#user_rut').val();
      tr = $(trs[i]);
      break;
    }
  }

  if (data !== null) {
		if (checkRut(rut)) {
	    $.ajax({
	      url: event.target.action,
	      data: data,
	      method: event.target.method,
	      beforeSend: function()
	      {
	        btn.val('Actualizando...');
	        btn.toggleClass('disabled');
	        showNotification({msg: "Actualizando usuario...", type: 'info', closeAll: true});

	      }
	    }).done(function(data, textStatus, jqXHR) {
	        noti_params.msg = data.msg;
	        noti_params.type = data.type;

	        data_table.DataTable().clear();
	        $('div#table_container').html(data.table);
	        data_table.DataTable().draw();

	        data_table = $('table#users_table');
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
		}else{
			// Rut invalido
			showNotification({msg: 'El rut ingresado no es válido.', type: 'danger', closeAll: true})
		}
  }
});