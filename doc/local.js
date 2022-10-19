jQuery(function($) {
  var current_page = window.location.pathname
  if (current_page == '/index.html') {
    current_page = '/'
  }
  $('.nav a[href="' + current_page + '"]').closest('li').addClass('active');

  $('.debian, .rubygems').each(function() {
    $(this).wrap('<div class="' + $(this).attr('class') + '"></div>');
  });

});
