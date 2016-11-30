var table = $('table#asis_table');
var datatable_options = {
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
        // Borrar los datos de la tabla.
        // var dt = table.DataTable();
        // dt.clear();
        // for (var i = 0; i < jqXHR.responseJSON.calificaciones.length; i++)
        // {
        //   var pa = new Date(Date.parse(jqXHR.responseJSON.calificaciones[i].periodo_academico));
        //   dt.row.add({
        //     "num": i + 1,
        //     "est_nombre": jqXHR.responseJSON.calificaciones[i].estudiante.nombre,
        //     "est_apellido": jqXHR.responseJSON.calificaciones[i].estudiante.apellido,
        //     "carrera": jqXHR.responseJSON.calificaciones[i].estudiante.carrera.nombre,
        //     "asignatura": jqXHR.responseJSON.calificaciones[i].asignatura.nombre,
        //     "tipo_calificacion": jqXHR.responseJSON.calificaciones[i].nombre_calificacion,
        //     "calificacion": jqXHR.responseJSON.calificaciones[i].valor_calificacion,
        //     "periodo_academico": formatDateToSemesterPeriod(pa)
        //   });
        // }
        // dt.draw();
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