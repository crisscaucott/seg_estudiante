// Envio formulario con los filtros de las asistencias.
$('form#new_user').submit(function(event){
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
      btn.val('Cambiando contraseña...');
      btn.prop('disabled', true);
      showNotification({msg: 'Cambiando contraseña...', type: 'info', closeAll: true})
    }
  }).done(function(data, textStatus, jqXHR) {
      noti_params.msg = data.msg;
      noti_params.type = 'success';

  }).fail(function(jqXHR, textStatus, errorThrown) {

      noti_params.msg = errorThrown;
      noti_params.type = 'danger';

      if (jqXHR.responseJSON !== undefined)
      {
        noti_params.msg = jqXHR.responseJSON.msg;
        noti_params.type = jqXHR.responseJSON.type;
      }

  }).always(function(data, textStatus, errorThrown) {
      btn.prop('disabled', false);
      btn.val(btn_text);
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
  });

});