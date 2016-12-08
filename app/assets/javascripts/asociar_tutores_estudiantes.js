$('form#tutores_est_form').on('submit', function(event){
  event.preventDefault();
  data = $(event.target).serialize();
  btn = $(event.target).find('input[type=submit]');
  btn_text = btn.val();
  var noti_params = {msg: null, type: null};

  $.ajax({
    url: event.target.action,
    data: data,
    method: event.target.method,
    beforeSend: function()
    {
      btn.val('Agregando...');
      btn.toggleClass('disabled');
      showNotification({msg: "Guardando...", type: 'info', closeAll: true});
    }
  }).done(function(data, textStatus, jqXHR) {
      noti_params.msg = data.msg;
      noti_params.type = data.type;


  }).fail(function(jqXHR, textStatus, errorThrown) {
      noti_params.msg = errorThrown;
      noti_params.type = 'danger';

      if (jqXHR.responseJSON !== undefined)
      {
        noti_params.msg = jqXHR.responseJSON.msg;
        noti_params.type = jqXHR.responseJSON.type;
      }

  }).always(function(data, textStatus, errorThrown) {
      btn.toggleClass('disabled');
      btn.val(btn_text);
      showNotification({msg: noti_params.msg, type: noti_params.type, closeAll: true})

  });
});

$('.list-group.checked-list-box .list-group-item').each(function () {
  // Settings
  var $widget = $(this),
  $checkbox = $widget.find('input[type=checkbox]'),
  color = ($widget.data('color') ? $widget.data('color') : "primary"),
  style = ($widget.data('style') == "button" ? "btn-" : "list-group-item-"),
  settings = {
      on: {
          icon: 'glyphicon glyphicon-check'
      },
      off: {
          icon: 'glyphicon glyphicon-unchecked'
      }
  };

  // Event Handlers
  $widget.on('click', function () {
      $checkbox.prop('checked', !$checkbox.is(':checked'));
      $checkbox.triggerHandler('change');
      updateDisplay();
  });

  $checkbox.on('change', function () {
      updateDisplay();
  });
    
  // Actions
  function updateDisplay() {
    var isChecked = $checkbox.is(':checked');

    // Set the button's state
    $widget.data('state', (isChecked) ? "on" : "off");

    // Set the button's icon
    $widget.find('.state-icon')
        .removeClass()
        .addClass('state-icon ' + settings[$widget.data('state')].icon);

    // Update the button's color
    if (isChecked) {
        $widget.addClass(style + color + ' active');
    } else {
        $widget.removeClass(style + color + ' active');
    }
  }

  // Initialization
  function init() {
      
    if ($widget.data('checked') == true) {
        $checkbox.prop('checked', !$checkbox.is(':checked'));
    }
    
    updateDisplay();

    // Inject the icon if applicable
    if ($widget.find('.state-icon').length == 0) {
        $widget.prepend('<span class="state-icon ' + settings[$widget.data('state')].icon + '"></span>');
    }
  }
  init();
});
