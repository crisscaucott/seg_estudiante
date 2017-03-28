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


$('div#asistencia_container').on('click', 'button.ver-detail', function (event){
  var btn = $(this);
  var btn_text = btn.text();
  // var tds = $(this).parent().parent().find('td');
  var data = $(this).parents('tr').data();
  var noti_params = {msg: null, type: 'info'};

  $.ajax({
    url: "/carga_masiva/asistencia/asistencia_detalle",
    data: {periodo: data.periodo, estudiante_id: data.estudianteId, asignatura_id: data.asignaturaId},
    method: "post",
    beforeSend: function()
    {
      btn.text('Cargando...');
      btn.toggleClass('disabled');
    }
  }).done(function(data, textStatus, jqXHR) {
      noti_params.msg = data.msg;
      noti_params.type = data.type;

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
      btn.text(btn_text);
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
  }); 
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
      table.DataTable().clear();
      $('div#asistencia_container').html(data.table);
      table.DataTable().draw();

      table = $('table#asis_table');
      if (data.table !== undefined)
        initDataTable(table, datatable_options);

      noti_params.msg = data.msg;
      noti_params.type = data.type;

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

$("select#filters_carrera").on('change', function(event){
  var carrera_id = $("option:selected", this).val();
  var noti_params = {msg: null, type: 'info'};
  var asignatura_select = $('select#filters_asignatura');

  if (carrera_id.length != 0) {
    $.ajax({
      url: '/carga_masiva/notas/ver/get_asignaturas',
      data: {carrera_id: carrera_id},
      method: 'post',
      beforeSend: function()
      {
        prepareAsignaturaCombo();
        asignatura_select.prop('disabled', true);
        showNotification({msg: "Obteniendo asignaturas por carrera...", type: 'info', closeAll: true});
      }
    }).done(function(data, textStatus, jqXHR) {
        noti_params.msg = data.msg;
        noti_params.type = data.type;

        // Agregar las asignaturas obtenidas del servidor.
        for (var i = 0; i < data.asignaturas.length; i++) {
          asignatura_select.append('<option value="' + data.asignaturas[i].id +'">' + data.asignaturas[i].nombre + '</option>');
        }

    }).fail(function(jqXHR, textStatus, errorThrown) {
        noti_params.msg = errorThrown;
        noti_params.type = 'danger';

        if (jqXHR.responseJSON !== undefined)
        {
          noti_params.msg = jqXHR.responseJSON.msg;
          noti_params.type = jqXHR.responseJSON.type;
        }

    }).always(function(data, textStatus, errorThrown) {
        asignatura_select.prop('disabled', false);
        showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
    });
  }else{
    prepareAsignaturaCombo();
  }
});

function prepareAsignaturaCombo()
{
  var asignatura_select = $('select#filters_asignatura');
  // Quitar todas las opciones de asignaturas.
  asignatura_select.empty();
  // Agregar la primera de "cualquiera"
  asignatura_select.append('<option value>Cualquiera</option>');
}