$('.type_tile p').live('click', function(){
    if(!$(this).prev('input[type="checkbox"]').prop('checked')){
        $(this).prev('input[type="checkbox"]').prop('checked', true).attr('checked','checked');
        this.style.background = '#ff7d00';
    }else{
        $(this).prev('input[type="checkbox"]').prop('checked', false).removeAttr('checked');
        this.style.background = '#4FAA60';
    }
});