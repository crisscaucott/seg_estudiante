var table = $('table#asis_table');
var datatable_options = {
    created_row: function( row, data, dataIndex ) {
      if (/\|/.test(data.estudiante)){
        aux_est = data.estudiante.split("|")
        $(row).find('td:eq(1)').html(aux_est[0]);
        $(row).find('td:eq(1)').attr('data-estudiante-id', aux_est[1]);
      }
      if (/\|/.test(data.asignatura)) {
        aux_asig = data.asignatura.split("|")
        $(row).find('td:eq(2)').html(aux_asig[0]);
        $(row).find('td:eq(2)').attr('data-asignatura-id', aux_asig[1]);
      }
      if (data.accion == null) {
        $(row).find('td:eq(3)').html("<button name='button' type='submit' class='btn btn-primary ver-detail'>Ver</button>");
      }
    },
    dom: 'ftip',
    columns: [
      {"data": "num"}, 
      {"data": "estudiante"}, 
      {"data": "asignatura"}, 
      {"data": "accion", "default": "ASD"}, 
    ],
  }
initDataTable(table, datatable_options);

table.on('click', 'button.ver-detail', function(event){
  var btn = $(this);
  var btn_text = btn.val();
  var tds = $(this).parent().parent().find('td');
  var data = {estudiante_id: null, asignatura_id: null};
  var noti_params = {msg: null, type: 'info'};

  for (var i = 0; i < tds.length; i++) {
    if ($(tds[i]).data('estudianteId') !== undefined)
      data.estudiante_id = $(tds[i]).data('estudiante-id');

    if ($(tds[i]).data('asignaturaId') !== undefined)
      data.asignatura_id = $(tds[i]).data('asignatura-id');
  }

  if (data.estudiante_id !== null && data.asignatura_id !== null) {
    $.ajax({
      url: "/carga_masiva/asistencia/asistencia_detalle",
      data: data,
      method: "post",
      beforeSend: function()
      {
        btn.val('Cargando...');
        btn.toggleClass('disabled');
      }
    }).done(function(data, textStatus, jqXHR) {
        noti_params.msg = jqXHR.responseJSON.msg;
        noti_params.type = jqXHR.responseJSON.type;

        bootbox.alert({
          size: 'large',
          title: data.title,
          message: data.table
        });

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
        showNotification({msg: noti_params.msg, type: noti_params.type})
    }); 
  }
});

// Envio formulario con los filtros de las asistencias.
$('form#filters_form').submit(function(event){
  var data, btn, btn_text, noti_params = {msg: null, type: 'info'};
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
      btn.val('Filtrando...');
      btn.toggleClass('disabled');
    }
  }).done(function(data, textStatus, jqXHR) {
      // Borrar los datos de la tabla.
      console.log(jqXHR.responseJSON);
      var dt = table.DataTable();
      dt.clear();
      for (var i = 0; i < jqXHR.responseJSON.asistencias.length; i++)
      {
        // var pa = new Date(Date.parse(jqXHR.responseJSON.calificaciones[i].periodo_academico));
        dt.row.add({
          "num": i + 1,
          "estudiante": jqXHR.responseJSON.asistencias[i].estudiante.nombre + " " + jqXHR.responseJSON.asistencias[i].estudiante.apellido + "|" +jqXHR.responseJSON.asistencias[i].estudiante_id,
          "asignatura": jqXHR.responseJSON.asistencias[i].asignatura.nombre + "|" +jqXHR.responseJSON.asistencias[i].asignatura_id,
          "accion": null
        });
      }
      dt.draw();
      noti_params.msg = jqXHR.responseJSON.msg;
      noti_params.type = 'success';

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
      showNotification({msg: noti_params.msg, type: noti_params.type})
  });

});