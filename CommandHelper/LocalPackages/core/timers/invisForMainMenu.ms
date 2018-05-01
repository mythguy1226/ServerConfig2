set_cron('* * * * *',closure(

    @plrs = players_in_radius(array('x':'0','y':'101','z':'0','world':'mainmenu'),3)

    //console('DOING CRON!')
    foreach(@plr in @plrs){
        //console(@plr)
        set_peffect(@plr,14,1,64,true,false)
    }
))

set_cron('*/5 * * * *',closure(
    @plrs = all_players()

    @scores = array()
    foreach(@plr in @plrs){
        @score = get_pscore('ReverseTag',@plr)
        @arScore = array('name': @plr,'score': @score)
        array_push(@scores,@arScore)
    }

    array_sort(@scores, closure(@left, @right){
        return(@left['score'] < @right['score']);
    });

    @numPlrs = array_size(@scores)

    if(@numPlrs > 0){
        @place = 1
        @winner = ''
        for(@i = 0, @i < @numPlrs, @i++){
            if(@scores[@i]['score'] != 0){
                broadcast(color('GREEN').@place.'. '.color('YELLOW').@scores[@i]['name'])
                @place++
                if(@winner == ''){
                    @winner = @scores[@i]['name']
                    set_pscore('ReverseTag',@scores[@i]['name'],0)
                }
            }
        }
        broadcast(color('RED').color('BOLD').@winner.color('DARK_GREEN').color('ITALIC').' has won an arcade token!')
        broadcast(color('DARK_GREEN').color('ITALIC').'Use '.color('RED').color('BOLD').'/baltop'.color('DARK_GREEN').color('ITALIC').' to see the richest player!')
        runas('~console','/eco give '.@winner.' 1')
    }
    broadcast(color('GRAY').color('ITALIC').'ReverseTag payouts every 5 minutes!')
))