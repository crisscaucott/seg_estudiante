var notas_form = $('#estudiantes_form');
var wrapper = notas_form.find('.progress-wrapper');
var progress_bar = wrapper.find('.progress-bar');

$(":file").filestyle('buttonText', 'Subir archivo');
$(":file").filestyle('buttonName', 'btn btn-primary');
$(":file").filestyle('placeholder', '.xls');