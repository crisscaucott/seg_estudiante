var table = $('table#notas_table');
var datatable_options = {
    dom: 'ftip',
    columns: [
      {"data": "num"}, 
      {"data": "est_nombre"}, 
      {"data": "est_apellido"}, 
      {"data": "carrera"}, 
      {"data": "asignatura"}, 
      {"data": "tipo_calificacion"},
      {"data": "calificacion"},
      {"data": "periodo_academico"}
    ],
  }

initDataTable(table, datatable_options);

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
      var dt = table.DataTable();
      dt.clear();
      for (var i = 0; i < jqXHR.responseJSON.calificaciones.length; i++)
      {
        var pa = new Date(Date.parse(jqXHR.responseJSON.calificaciones[i].periodo_academico));
        dt.row.add({
          "num": i + 1,
          "est_nombre": jqXHR.responseJSON.calificaciones[i].estudiante.nombre,
          "est_apellido": jqXHR.responseJSON.calificaciones[i].estudiante.apellido,
          "carrera": jqXHR.responseJSON.calificaciones[i].estudiante.carrera.nombre,
          "asignatura": jqXHR.responseJSON.calificaciones[i].asignatura.nombre,
          "tipo_calificacion": jqXHR.responseJSON.calificaciones[i].nombre_calificacion,
          "calificacion": jqXHR.responseJSON.calificaciones[i].valor_calificacion,
          "periodo_academico": formatDateToSemesterPeriod(pa)
        });
      }
      dt.draw();
      noti_params.msg = jqXHR.responseJSON.msg;
      noti_params.type = 'success';

  }).fail(function(jqXHR, textStatus, errorThrown) {

      noti_params.msg = jqXHR.responseJSON.msg;
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