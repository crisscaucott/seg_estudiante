var desasociar = false;
var show_inputs = false;
var settings = {
  on: {
      icon: 'glyphicon glyphicon-check'
  },
  off: {
      icon: 'glyphicon glyphicon-unchecked'
  }
};

$('input#desasociar_btn').on('click', function(event){
  var checkboxes = $(event.target).parents('form').find('input[type=checkbox]');

  if (desasociar) {
    desasociar = false;
    $(event.target).val('Desasociar');
    updateSpanIcons(checkboxes);
    updateAllDisplays(checkboxes);

  }else{
    desasociar = true;
    updateSpanIcons(checkboxes);
    $(event.target).val('Cancelar');
  }
});

// Evento de click en cada tutor para pode traer a los estudianres asociados a el.
$('div.funkyradio-primary > label').on('click', function(event){
  // event.preventDefault();
  var form = $('form#tutores_form');
  var data = form.serializeArray();
  var inputs = $(this).parent().find('input');
  var noti_params = {msg: null, type: null};
  var submit_btn = form.find('input[type=submit]');

  data.push({name: inputs.attr('name'), value: inputs.attr('value')})

  $.ajax({
    url: '/carga_masiva/tutores/get_estudiantes',
    data: data,
    method: form[0].method,
    beforeSend: function()
    {
      $('div#estudiantes_list').empty();
      showNotification({msg: "Obteniendo estudiantes asociados...", type: 'info', closeAll: true});
    }
  }).done(function(data, textStatus, jqXHR) {
      desasociar = false;
      noti_params.msg = data.msg;
      noti_params.type = data.type;

      $('div#estudiantes_list').html(data.estudiantes_list);
      init2();

      $('input#desasociar_btn').prop('disabled', false);
      $('input#desasociar_btn').val('Desasociar');
      submit_btn.prop('disabled', false);

  }).fail(function(jqXHR, textStatus, errorThrown) {
      desasociar = false;
      noti_params.msg = errorThrown;
      noti_params.type = 'danger';

      if (jqXHR.responseJSON !== undefined)
      {
        noti_params.msg = jqXHR.responseJSON.msg;
        noti_params.type = jqXHR.responseJSON.type;
      }
      $('input#desasociar_btn').prop('disabled', true);
      $('input#desasociar_btn').val('Desasociar');
      submit_btn.prop('disabled', true);

  }).always(function(data, textStatus, errorThrown) {
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})
  });
});

// Enviar formulario de desasociacion de estudiantes.
$('form#tutores_form').on('submit', function(event){
  event.preventDefault();
  data = $(event.target).serialize();
  btn = $(event.target).find('input[type=submit]');
  btn_text = btn.val();
  var noti_params = {msg: null, type: null};

  $.ajax({
    url: (event.target).action,
    data: data,
    method: (event.target).method,
    beforeSend: function()
    {
      btn.prop('disabled', true);
      btn.val('Guardando...');
      showNotification({msg: "Desasociando estudiantes a tutor...", type: 'info', closeAll: true});
    }
  }).done(function(data, textStatus, jqXHR) {
      noti_params.msg = data.msg;
      noti_params.type = data.type;

      if (data.estudiantes_list === null) {
        // No quedan mas estudiantes asociados al tutor.
        // Vaciar div contenedor de estudiantes.
        $('div#estudiantes_list').empty();
        // Cambiar a falso la variable indicadora de desasociacion.
        desasociar = false;
        // Cambiar el mensaje del boton para desasociar.
        $('input#desasociar_btn').prop('disabled', true);
        $('input#desasociar_btn').val('Desasociar');

      }else{
        // Aun quedan estudiantes asociados.
        $('div#estudiantes_list').html(data.estudiantes_list);
        init2();
        var checkboxes = $(event.target).find('input[type=checkbox]');
        updateSpanIcons(checkboxes);
        updateAllDisplays(checkboxes);
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
      if (data.estudiantes_list === null) {
        btn.prop('disabled', true);
      }else{
        btn.prop('disabled', false);
      }
      btn.val(btn_text);
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})

  });
});

function init2() {

  $('ul#check-list-box > li.list-group-item').on('click', function(event){
    var $widget;
    if (event.target.nodeName === "LI") {
      $widget = $(event.target);
    }else{
      $widget = $(event.target).parents('li');
    }

    event.preventDefault();
    var $checkbox = $widget.find('input[type=checkbox]');
    var color = ($widget.data('color') ? $widget.data('color') : "danger");
    var style = ($widget.data('style') == "button" ? "btn-" : "list-group-item-");

    if (desasociar) {
      // Event Handlers
      $checkbox.prop('checked', !$checkbox.is(':checked'));
      $checkbox.triggerHandler('change');
      updateDisplay($checkbox, $widget, style, color);      
    }

    $checkbox.on('change', function (event) {
        updateDisplay($checkbox, $widget, style, color);
    });
      
    
    // Initialization
    function init1() {
        
      if ($widget.data('checked') == true) {
          $checkbox.prop('checked', !$checkbox.is(':checked'));
      }
      
      updateDisplay();

      // Inject the icon if applicable
      if ($widget.find('.state-icon').length == 0) {
          $widget.prepend('<span class="state-icon ' + settings[$widget.data('state')].icon + '"></span>');
      }
    }
    // init1();
  });
}

function updateSpanIcons (checkboxes) {
  for (var i = 0; i < checkboxes.length; i++) {
    var span_icon = $(checkboxes[i]).parents('li').find('span');

    if (desasociar){
      span_icon.removeClass('hidden');
    }
    else{
      span_icon.addClass('hidden');
      span_icon.removeClass(settings.on.icon);
      span_icon.addClass(settings.off.icon);
    }
  }
}

function updateAllDisplays(checkboxes) {
  for (var i = 0; i < checkboxes.length; i++) {
    var widget = $(checkboxes[i]).parents('li');
    var color = (widget.data('color') ? widget.data('color') : "danger");
    var style = (widget.data('style') == "button" ? "btn-" : "list-group-item-");
    $(checkboxes).prop('checked', false);
    updateDisplay($(checkboxes[i]), widget, style, color, false);
  }
}

// Actions
function updateDisplay(checkbox, widget, style, color, set_icon = true) {
  var isChecked = checkbox.is(':checked');

  // Set the button's state
  widget.data('state', (isChecked) ? "on" : "off");

  if (set_icon) {
    widget.find('.state-icon')
        .removeClass()
        .addClass('state-icon ' + settings[widget.data('state')].icon);
  }
  // Set the button's icon

  // Update the button's color
  if (isChecked) {
      widget.addClass(style + color);
  } else {
      widget.removeClass(style + color);
  }
}