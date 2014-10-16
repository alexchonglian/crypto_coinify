App.views.User.addChild('UserUsercoins', _.extend({
  el: '#user_usercoins',

  activate: function(){
    var that = this;
    this.$loader = this.$(".loading img");
    this.$loaderDiv = this.$(".loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
    this.parent.on('selectTab', function(){
      if(that.$el.is(':visible')){
        that.fetchPage();
      }
    });
  }

}, Skull.InfiniteScroll));


$(document).ready(function() {
  $('.tablerow_division').each(function(index) {
      $(this).hide();
      $(this).css('height','200px');
  });

  $('.usercoins_table_row').on('click', function(e) {
      e.preventDefault();
      $(this).next().toggle('fast');
  });
});