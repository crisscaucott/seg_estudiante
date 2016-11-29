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
  