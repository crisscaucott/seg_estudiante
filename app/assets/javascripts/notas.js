var notas_form = $('#notas_form');
var wrapper = notas_form.find('.progress-wrapper');
var progress_bar = wrapper.find('.progress-bar');

$(":file").filestyle('buttonText', 'Subir archivo');
$(":file").filestyle('buttonName', 'btn btn-primary');
$(":file").filestyle('placeholder', '.xls | .csv');

notas_form.fileupload({
	dataType: 'json',
	add: function (e, data) {
    types = /(\.|\/)(torrent|jpe?g|png|bmp)$/i;
    file = data.files[0];
    if (types.test(file.type) || types.test(file.name)) {
      data.submit();
    }
    else{
  		showNotification({msg: 'Solo se admiten archivos tipo excel.', type: 'warning', closeAll: true});
    }
  },
	// Empieza la subida del archivo
  start: function(e){
		// Reiniciar barra de progreso.
		progress_bar.width(0);
	  progress_bar.text('0%');
  },
  send: function(e, data){
  	showNotification({msg: 'Subiendo archivo...', type: 'info'});
  },
	// Subida en progreso.
  progressall: function(e, data){
		// data.loaded => numero de bytes cargados
		// data.total => cantidad total de bytes a subir
	  var progress = parseInt(data.loaded / data.total * 100, 10);
	  progress_bar.css('width', progress + '%').text(progress + '%');
  },
	// Termina la subida del archivo
  done: function(e, data){
  	var res = data.jqXHR.responseJSON;
  	console.log(e);
  	console.log(data);
  	showNotification({msg: res.msg, type: 'success', closeAll: true});
  },
  // Falla la subida.
  fail: function(e, data){
  	console.log(e);
  	console.log(data);
  	showNotification({msg: data.errorThrown, type: 'danger', closeAll: true});
  },
  always: function(e, data){
  	console.log(e);
  	console.log(data);
  }

});