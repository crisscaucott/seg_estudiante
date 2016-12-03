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