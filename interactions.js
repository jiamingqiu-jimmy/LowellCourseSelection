// For Future Needs
$(document).ready(function(){
  $.ajax({
    type: 'GET',
    url: '/class-select',
    success: function() {
      console.log('success', "Hi");
    }
  });
});