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

$('div.funkyradio-primary > label').on('click', function(event){
  // event.preventDefault();
  var form = $('form#tutores_form');
  var data = form.serializeArray();
  var inputs = $(this).parent().find('input');
  var noti_params = {msg: null, type: null};
  var submit_btn = form.find('input[type=submit]');

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
      // desasociar = true;
      noti_params.msg = data.msg;
      noti_params.type = data.type;

      $('div#estudiantes_list').html(data.estudiantes_list);
      init2();

      $('input#desasociar_btn').prop('disabled', false);
      submit_btn.prop('disabled', false);

  }).fail(function(jqXHR, textStatus, errorThrown) {
      // desasociar = false;
      noti_params.msg = errorThrown;
      noti_params.type = 'danger';

      if (jqXHR.responseJSON !== undefined)
      {
        noti_params.msg = jqXHR.responseJSON.msg;
        noti_params.type = jqXHR.responseJSON.type;
      }
      $('input#desasociar_btn').prop('disabled', true);
      submit_btn.prop('disabled', true);

  }).always(function(data, textStatus, errorThrown) {
    // checkDesasociarSubmitBtn();
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})

  });
});

$('form#tutores_form').on('submit', function(event){
  event.preventDefault();
  console.log(event);
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
  // if (desasociar) {
    for (var i = 0; i < checkboxes.length; i++) {
      var widget = $(checkboxes[i]).parents('li');
      var color = (widget.data('color') ? widget.data('color') : "danger");
      var style = (widget.data('style') == "button" ? "btn-" : "list-group-item-");
      $(checkboxes).prop('checked', false);
      updateDisplay($(checkboxes[i]), widget, style, color, false);
    }
  // }
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

$('form#tutores_form').on('submit', function(event){
  event.preventDefault();


});