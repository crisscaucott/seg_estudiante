var data_table = $('table#estados_table');
var datatable_options = {
    dom: 'tip',
    columns: [
      {"data": "num"}, 
      {"data": "nombre_estado"}, 
      {"data": "notifica"},
      {"data": "riesgoso"},
      {"data": "editar"},
    ],
  }

initDataTable(data_table, datatable_options);

// Evento de click en el boton "editar" de la tabla de deserciones.
$('div#table_container').on('click', 'button.edit_btn', function(event){
  var tr = $(this).parents('tr');
  var trs = $(this).parents('tbody').children();
  var submit_btn = $("form#edit_estado_desercion_form").find('input[type=submit]');

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
        $(trs[i]).find('input').removeClass('hidden');
        $(trs[i]).find('input.row_edited').val(1);

        // Habilitar el boton submit de finalizar
        submit_btn.attr('disabled', false);

      }else{
        $(trs[i]).find('span').removeClass('hidden');
        $(trs[i]).find('input').addClass('hidden');
        $(trs[i]).find('input.row_edited').val(0);

        // Desabilitar el boton submit de finalizar.
        submit_btn.attr('disabled', true);
      }
      
    }else{
      $(trs[i]).removeClass('info');
      $(trs[i]).find('span').removeClass('hidden');
      $(trs[i]).find('input').addClass('hidden');
      $(trs[i]).find('input.row_edited').val(0);
    }
  }
});

// Evento de click en el boton "Eliminar" de la tabla de deserciones.
$('div#table_container').on('click', 'button.delete_btn', function(event){
  var tr = $(this).parents('tr');
  var trs = $(this).parents('tbody').children();
  var submit_btn = $("form#edit_estado_desercion_form").find('input[type=submit]');
  
  for(var i = 0; i < trs.length; i++){
    if (tr[0].rowIndex === trs[i].rowIndex){ // Fila de la tabla donde se va a editar.
      $(trs[i]).removeClass('info');
      $(trs[i]).toggleClass('danger');

      if ($(trs[i]).hasClass('danger')){
        $(trs[i]).find('span').removeClass('hidden');
        $(trs[i]).find('input').addClass('hidden');
        $(trs[i]).find('input.row_edited').val(0);
        $(trs[i]).find('input.row_delete').val(1);

        // Habilitar el boton submit de finalizar
        submit_btn.attr('disabled', false);

      }else{
        $(trs[i]).find('span').removeClass('hidden');
        $(trs[i]).find('input').addClass('hidden');
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

// Envio de formulario de edicion de estados de desercion de la tabla.
$('div#table_container').on('submit', 'form#edit_estado_desercion_form', function(event){
  event.preventDefault();
  var trs = data_table.find('tbody').children(), tr = null, hidden_upd = null, hidden_del = null, data = null, noti_params = {msg: null, type: null}, btn = $(event.target).find('input[type=submit]'), btn_text = btn.val();

  for (var i = 0; i < trs.length; i++)
  {
    hidden_upd = $(trs[i]).find('input.row_edited').val();
    hidden_del = $(trs[i]).find('input.row_delete').val();
    
    if (hidden_upd == 1 || hidden_del == 1){
      data = $(trs[i]).find('input').serialize();
      tr = $(trs[i])
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
        btn.val('Actualizando...');
        btn.toggleClass('disabled');
        showNotification({msg: "Actualizando estado...", type: 'info', closeAll: true});

      }
    }).done(function(data, textStatus, jqXHR) {
        noti_params.msg = data.msg;
        noti_params.type = data.type;

        data_table.DataTable().clear();
        $('div#table_container').html(data.table);
        data_table.DataTable().draw();

        data_table = $('table#estados_table');
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
  }
});