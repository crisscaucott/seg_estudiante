// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap.min
//= require bootstrap-filestyle.min
//= require bootstrap-notify.min
//= require jquery.remotipart
//= require jquery-fileupload/basic
//= require jquery.dataTables.min
//= require dataTables.bootstrap.min
//= require bootbox.min

var notifications = [];
var notifications_limit = 3;

function showNotification(options)
{
	var type, title, dismissable;
	type = options.type === null ? 'info' : options.type;
	title = options.title === null ? null : options.title;
	dismissable = options.dismiss === null ? true : options.dismiss;

	if (options.closeAll !== null && options.closeAll)
	{
		$.notifyClose();
		notifications = [];
	}

	notif = $.notify({
		// options
		// icon: 'glyphicon glyphicon-warning-sign',
		title: title,
		message: options.msg,
	},{
		// settings
		type: type,
		allow_dismiss: dismissable,
		newest_on_top: true,
		placement: {
			from: "top",
			align: "right"
		},
		offset:{
			y: 68,
			x: 5
		},
		spacing: 10,
		delay: 0,
		timer: 1000,
		animate: {
			enter: 'animated fadeInRight',
			exit: 'animated fadeOutRight'
		},
		icon_type: 'class',
	});

	checkNotifications(notif);
}

function formatDateToSemesterPeriod(date)
{
	var semester = date.getUTCMonth() < 6 ? "1" : "2";
	return String(date.getUTCFullYear()) + " - " + String(semester);
}

function checkNotifications(noti)
{
	if (notifications.length >= notifications_limit)
	{
		notifications[0].close();
		notifications.shift();
	}
	notifications.push(notif);
}

function initDataTable(data_table, options)
{
	var dom;
	if (options.dom === undefined || options.dom === null)
	  dom = 'lrtip';
	else
	  dom = options.dom;

	created_row = options.created_row !== undefined ? options.created_row : null

	data_table.dataTable({
		"createdRow": created_row,
    "dom": dom,
		"order": [[1, 'asc']],
		"columns": options.columns,
		"language": {
	    "sProcessing":    "Procesando...",
	    "sLengthMenu":    "Mostrar _MENU_ registros",
	    "sZeroRecords":   "No se encontraron resultados",
	    "sEmptyTable":    "Ningún dato disponible en esta tabla",
	    "sInfo":          "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
	    "sInfoEmpty":     "Mostrando registros del 0 al 0 de un total de 0 registros",
	    "sInfoFiltered":  "(filtrado de un total de _MAX_ registros)",
	    "sInfoPostFix":   "",
	    "sSearch":        "Buscar:",
	    "sUrl":           "",
	    "sInfoThousands":  ",",
	    "sLoadingRecords": "Cargando...",
	    "oPaginate": {
	        "sFirst":   "Primero",
	        "sLast":    "Último",
	        "sNext":    "Siguiente",
	        "sPrevious": "Anterior"
	    },
	    "oAria": {
	        "sSortAscending":  ": Activar para ordenar la columna de manera ascendente",
	        "sSortDescending": ": Activar para ordenar la columna de manera descendente"
	    }
		}
	});
}

