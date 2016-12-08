$('div.funkyradio-primary > label').on('click', function(event){
  // event.preventDefault();
  console.log("click");
  var form = $('form#tutores_form');
  var data = form.serializeArray();
  var inputs = $(this).parent().find('input');
  var noti_params = {msg: null, type: null};

  data.push({name: inputs.attr('name'), value: inputs.attr('value')})

  $.ajax({
    url: form[0].action,
    data: data,
    method: form[0].method,
    beforeSend: function()
    {
      $('div#estudiantes_list').empty();
      showNotification({msg: "Obteniendo estudiantes asociados...", type: 'info', closeAll: true});
    }
  }).done(function(data, textStatus, jqXHR) {
      noti_params.msg = data.msg;
      noti_params.type = data.type;

      $('div#estudiantes_list').html(data.estudiantes_list);

  }).fail(function(jqXHR, textStatus, errorThrown) {
      noti_params.msg = errorThrown;
      noti_params.type = 'danger';

      if (jqXHR.responseJSON !== undefined)
      {
        noti_params.msg = jqXHR.responseJSON.msg;
        noti_params.type = jqXHR.responseJSON.type;
      }

  }).always(function(data, textStatus, errorThrown) {
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})

  });

});