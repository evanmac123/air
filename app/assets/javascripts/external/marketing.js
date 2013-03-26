if(location.search)
    alert(location.search);

$('.type_tile img').live('click', function(){
    if(!$(this).prev('input[type="checkbox"]').prop('checked')){
        $(this).prev('input[type="checkbox"]').prop('checked', true).attr('checked','checked');
        this.style.border = '5px solid #4FAA60';
        this.style.margin = '0px';
    }else{
        $(this).prev('input[type="checkbox"]').prop('checked', false).removeAttr('checked');
        this.style.border = '0';
        this.style.margin = '5px';
    }
});