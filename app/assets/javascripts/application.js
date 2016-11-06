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

function checkNotifications(noti)
{
	if (notifications.length >= notifications_limit)
	{
		notifications[0].close();
		notifications.shift();
	}
	notifications.push(notif);
}
