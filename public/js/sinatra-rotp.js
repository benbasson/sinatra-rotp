function updateQRCode () {
  var secret = $('#secret').text();
  var user = $('#username').val();
  var issuer = $('#issuer').val();

  if (user.length > 0) {
    $('#username').parents('.form-group').removeClass("has-error");
    $('#qr-code').attr('src', '/get-otp-qr-code/' + encodeURIComponent(user) + '/' + encodeURIComponent(secret) + '/' + encodeURIComponent(issuer));
  }
  else {
    $('#username').parents('.form-group').addClass("has-error");
  }
}

function updateOTPCode () {
  var secret = $('#secret').text();
  $.ajax({
    url: '/current-otp-code/' + encodeURIComponent(secret),
    accepts: 'text/plain',
    success: function (data, status, jqxhr) {
      $('#otpcode').text(data);
      updateCountdown();
    },
    error: function (jqxhr, status, error) {
    }
  });
}

function updateCountdown ()  {
  // Set time to countdown to next 30 second change
  var time = new Date();
  var seconds = time.getSeconds();
  if (seconds >= 30) {
    time.setMinutes(time.getMinutes()+1);
    time.setSeconds(0);
  }
  else {
    time.setSeconds(30);
  }
  $('#countdown').countdown(time, function(event) {
    $(this).text(event.strftime('%M:%S'));
  });
}

$(document).ready(function (){
  $('a.refresh-link').on('click', function (){
    $.ajax({
      url: '/generate-secret',
      accepts: 'text/plain',
      success: function (data, status, jqxhr) {
        $('#secret').text(data);
        updateQRCode();
        updateOTPCode();
      },
      error: function (jqxhr, status, error) {
      }
    });
  });
  $('.user-editable').on('keyup cut paste', function () {
    updateQRCode();
  });
  $('#countdown').on('finish.countdown', function () {
    updateOTPCode();
    $('#countdown').text('00:30');
    setTimeout(function (){
      updateCountdown();
    },1000);

  });
  updateCountdown();
});