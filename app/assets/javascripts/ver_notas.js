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
  var data, btn, btn_text;
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
        dt.row.add({
          "num": i + 1,
          "est_nombre": jqXHR.responseJSON.calificaciones[i].estudiante.nombre,
          "est_apellido": jqXHR.responseJSON.calificaciones[i].estudiante.apellido,
          "carrera": jqXHR.responseJSON.calificaciones[i].estudiante.carrera.nombre,
          "asignatura": jqXHR.responseJSON.calificaciones[i].asignatura.nombre,
          "tipo_calificacion": jqXHR.responseJSON.calificaciones[i].nombre_calificacion,
          "calificacion": jqXHR.responseJSON.calificaciones[i].valor_calificacion,
          "periodo_academico": jqXHR.responseJSON.calificaciones[i].periodo_academico
        });
      }
      dt.draw();
      
      showNotification({msg: jqXHR.responseJSON.msg, type: 'success'})

  }).fail(function(jqXHR, textStatus, errorThrown) {
      showNotification({msg: jqXHR.responseJSON.msg, type: jqXHR.responseJSON.type})

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

});