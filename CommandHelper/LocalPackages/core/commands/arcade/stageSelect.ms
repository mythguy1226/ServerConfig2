register_command('stageselect', 
    array(
        'description': 'Selects a stage',
        'usage': '/stageselect',
        'permission': 'command.stageselect',
        'noPermMsg': 'Sorry you don\'t have permission to use this command.',		
        'aliases': array('stagesel', 'findstage','ssel'),
        'executor': closure(@alias, @sender, @args) {
                @argNum = array_size(@args)
                if (@argNum != 0) {
                    msg(color('RED').'Try this: /stageselect')
                    return(false)
                }

                include('/home/minecraft/server/plugins/CommandHelper/includes/worldList.ms') 
                msg(color('YELLOW').'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
                foreach(@world in @worldList){
                    runas('~console','/tellraw '.@sender.' {"text":"'.@world[1].'","color":"gold","clickEvent":{"action":"run_command","value":"/goworld '.@world[0].'"},"hoverEvent":{"action":"show_text","value":"'.@world[1].'"}}')
                }
                msg(color('RED').'Click a stage to go there.')
                msg(color('YELLOW').'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
       ) }
    )


register_command('goworld', 
    array(
        'description': 'Goes to stage',
        'usage': '/goworld',
        'permission': 'command.goworld',
        'noPermMsg': 'Sorry you don\'t have permission to use this command.',		
        'executor': closure(@alias, @sender, @args) {
            include('/home/minecraft/server/plugins/CommandHelper/includes/getHeroClass.ms')
            @class = _getheroclass(@sender)
            @confirmed = import(@sender."stageConfirmed")
            if(@confirmed != @args[0]){
                export(@sender."stageConfirmed",@args[0])
                msg(@args[0].color('RED').' selected! Please click again to confirm your choice.')
                die()
            }
            try{
                @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/' . @class . '.yml')
                @hero = yml_decode(@contents)
            }catch(Exception @d){
                @hero = array()
                @hero['name'] = @sender
            } 

            @worldNiceName = ''
            include('/home/minecraft/server/plugins/CommandHelper/includes/worldList.ms')
            foreach(@world in @worldList){
                if(@world[0] == @args[0]){
                    runas('~console','/warp '.@args[0].' '.@sender)
                    @worldNiceName = @world[1]
                    broadcast(color('BLUE').@hero['name'].color('GRAY').color('ITALIC').' has entered '.@worldNiceName.'!')
                    set_timeout(2000,closure(
                        msg(color('RED').'Turn the autobuff off after you die using '.color('GREEN').'/autobuff off'.color('RED').' .')
                        msg(color('RED').'Your hunger will never be full on this server, '.color('GREEN').'to prevent regeneration'.color('RED').' .')
                        msg(color('RED').'Some characters have multiple skins! Try '.color('GREEN').'/skins'.color('RED').' !')
                        msg(color('RED').'Make your powers clickable with '.color('GREEN').'/powertool'.color('RED').' !')
                        msg(color('RED').'See your character skin with '.color('GREEN').'/dvs'.color('RED').' !')
                        msg(color('RED').'Regain health using '.color('GREEN').'/rest'.color('RED').' !')
                        msg(color('RED').'Exit back to the arcade with '.color('GREEN').'/exitgame'.color('RED').' !')
                        msg(color('RED').'Go somewhere else with '.color('GREEN').'/stageselect'.color('RED').' !')
                        msg(color('RED').'Select a new character using '.color('GREEN').'/mainmenu'.color('RED').' !')
                        msg(color('RED').'Check out your '.color('GREEN').'/powers'.color('RED').' !')
                        if(has_permission(@sender,'ch.alias.buff')){
                            runas(@sender,'/buff')
                        }
                        @puuid = puuid(@sender)
                        if(array_index_exists(@hero,'maxHearts')){
                            queue_push(closure(set_attribute(@puuid,'maxHealth',(@hero['maxHearts'] * 2))))
                            queue_push(closure(set_phealth(@sender,(@hero['maxHearts'] * 2))))
                        }else{
                            queue_push(closure(set_attribute(@puuid,'maxHealth',20)))
                        }
                    ))
                }
            }

        }
    )
)
