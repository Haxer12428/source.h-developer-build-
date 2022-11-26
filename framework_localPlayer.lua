FW.localPlayer = {

    _ = { 

        storage = {

            events = {

                last_miss = 0; 
                last_missed_target = nil; 

            }; 

            info = {

                nade_preThrow = false; 
                nade_throwWait = false; 

                manual_shoot = false; 
                manual_preShoot = false; 
                manual_shootExploitCharged = 0;  

                on_ladder = false; 
                
                on_use = false; 

                move_state = nil;

            }; 

        }; 

        detect_cheatShoot = {

            singe_EventTrigger = function () 
                events.cheat_shoot:call(); 
            end; 

        }; 

        info = {
    
            nade_throwHandleWait = function (cmd) 
                local local_player = get_local_player(); 
                local local_weapon = local_player:get_player_weapon(); 

                if (local_weapon == nil) then 
                    return end; 

                local local_weapon_info = local_weapon:get_weapon_info(); 
                local weapon_is_nade = local_weapon_info.weapon_type == 9;  

                if (weapon_is_nade) then 
                    if (cmd.in_attack or cmd.in_attack2) then 
                        FW.localPlayer._.storage.info.nade_preThrow = true; 
                    end; end 

                if (FW.localPlayer._.storage.info.nade_preThrow) then  
                    if (not cmd.in_attack and not cmd.in_attack2) then 
                        FW.localPlayer._.storage.info.nade_preThrow = false; 
                        FW.localPlayer._.storage.info.nade_throwWait = true; 
                    end; end  

                if (FW.localPlayer._.storage.info.nade_throwWait) then 
                    if (not weapon_is_nade) then 
                        FW.localPlayer._.storage.info.nade_throwWait = false; 
                    end; end 
            end; 

            shoot_manualShootForceWait = function () 
                local local_player = get_local_player(); 
                local local_weapon = local_player:get_player_weapon(); 
                if (local_weapon == nil) then 
                    FW.localPlayer._.storage.info.manual_shoot = false; return end 

                local weapon_info = local_weapon:get_weapon_info(); 
                local allowed_weapons = {5; 1; 0}; 
                local allow_weap = false; 

                for _, weapon in pairs(allowed_weapons) do 
                    if (weapon_info.weapon_type == weapon) then 
                        allow_weap = true; 
                    end; end 
                
                if (not allow_weap) then 
                    FW.localPlayer._.storage.info.manual_preShoot = false; 
                    return end 

                FW.localPlayer._.storage.info.manual_preShoot = false; 

                if (FW.localPlayer._.storage.info.manual_shootExploitCharged > globals.tickcount + 50) then 
                    FW.localPlayer._.storage.info.manual_shootExploitCharged = 0; end 
                    
                if (FW.localPlayer._.storage.info.manual_preShoot ) then 
                    return end

                if (FW.localPlayer._.storage.info.manual_shootExploitCharged + 2 > globals.tickcount) then 
                    FW.localPlayer._.storage.info.manual_preShoot = true; 
                    return end 

                local delayed_ticks = FW._G["=>"].get_delayed_ticks();

                if (local_weapon["m_flNextPrimaryAttack"] - (2 + delayed_ticks)/64 > globals.curtime) then 
                    return end 
                
                if (common.is_button_down(1)) then 
                    FW.localPlayer._.storage.info.manual_preShoot = true; 
                    FW.localPlayer._.storage.info.manual_shootExploitCharged = rage.exploit:get() == 1 and globals.tickcount or 0; end 

            end; 

            shoot_manualShootDisableWait = function (args) 
                local shooter = entity.get(args.userid, true);

                if (shooter ~= get_local_player()) then 
                    return end 

                FW.localPlayer._.storage.info.manual_preShoot = false; 
            end;    

            on_ladderCheck = function ()
                local local_player = get_local_player(); 
                FW.localPlayer._.storage.info.on_ladder = local_player["m_MoveType"] == 9; 
            end; 

            on_use = function (cmd)
                FW.localPlayer._.storage.info.on_use = cmd.in_use; 
            end; 
            
            move_state = function (self, cmd)

                --// local player 
                local local_player = get_local_player(); 
        
                local flags = local_player["m_fFlags"]; 
                local velocity = FW.localPlayer["=>"].get_velocity(); 
        
                if (local_player == nil or velocity == nil) then return end  
        
                local check_state = { 
        
                    [1] = function ()
                        if ( bit.band(flags, 1) ~= 0 or velocity > 90 ) then return false; end
                        return "air_steady"; 
                    end;
        
        
                    [2] = function ()
                        if ( bit.band(flags, 1) ~= 0 or bit.band(flags, 4) ~= 4 ) then return false; end 
                        return "air_crouch"; 
                    end;
        
        
                    [3] = function ()
                        if ( bit.band(flags, 1) ~= 0 ) then return false; end 
                        return "air"; 
                    end;
        
        
                    [4] = function ()
                        if ( bit.band(flags, 4) ~= 4 or velocity <= 5 ) then return false; end 
                        return "crouch_move"; 
                    end;
        
        
                    [5] = function ()
                        if ( bit.band(flags, 4) ~= 4 ) then return false end 
                        return "crouch"; 
                    end;
        
        
                    [6] = function ()
                        if ( velocity <= 12.5 ) then return false end 
                        return "move"; 
                    end;
        
        
                    [7] = function ()
                        return "stand"; 
                    end;
        
                }
        
                for index = 1, #check_state do 
        
                    local called_state = check_state[index]();
        
                    if ( called_state ~= false ) then 
                        FW.localPlayer._.storage.info.move_state = called_state return end 
        
                end 
                
            end; 

            init = function (self, cmd) 

                self.nade_throwHandleWait(cmd); 
                self.shoot_manualShootForceWait(); 
                self.on_ladderCheck(); 
                self.on_use(cmd); 
                self:move_state(cmd);

            end; 
        }; 
        
        events = {

            on_miss = function (args) 
                local storage = FW.localPlayer._.storage.events; 
                local attacker = entity.get(args.userid, true); 

                if (attacker == nil) then 
                    return end 

                if (storage.last_miss + 2 > globals.tickcount and storage.last_missed_target == attacker) then 
                    return end 

                local local_player = get_local_player(); 

                if (local_player == nil or not local_player:is_alive()) then 
                    return end 

                if (not attacker:is_enemy() or attacker == local_player or not attacker:is_alive()) then 
                    return end 

                local attacker_eyes = attacker:get_eye_position(); 
                local local_head = local_player:get_hitbox_position(1);  
                local local_eyes = local_player:get_eye_position(); 

                local attacker_bullet = vector (args["x"], args["y"], args["z"]); 

                local closest_pointDefault = FW.math["=>"].closest_linePoint(local_head, attacker_eyes, attacker_bullet); 

                local closest_distanceDefault = closest_pointDefault.distance; 
                local closest_positionDefault = closest_pointDefault.position; 

                local minimal_distanceToPass = 125; 

                if (minimal_distanceToPass < closest_distanceDefault) then 
                    return end 

                if (utils_trace_bullet(local_player, local_eyes, closest_positionDefault) < 1) then 
                    return end 
                    
                storage.last_miss = globals.tickcount; 
                storage.last_missed_target = attacker; 
            
                local event_arguments = {
                    attacker = attacker; 
                    closest_distanceDefault = closest_distanceDefault;
                    closest_pointDefault = closest_pointDefault; 
                    distance_toPass = minimal_distanceToPass; 
                }; 

                events.missed_local:call(event_arguments);
            end; 

            on_death = function (e) 
                local death = entity.get(e.userid, true); 

                if (death ~= entity.get_local_player()) then 
                    return end 

                local attacker = entity.get(e.attacker, true); 
                local move_state = FW.localPlayer['=>'].info().move_state; 

                local arguments = {
                    move_state = move_state,
                    side = FW.angles['=>'].get_inverter(); 
                    attacker = attacker; 
                    headshoted = e.headshot;
                }; 

                events.local_death:call(arguments); 
            end; 

            init = function (self) 
                
                events.bullet_impact:set(
                    function (...) 
                        self.on_miss(...); 
                    end)

                events.player_death:set(
                    function (...)
                        self.on_death(...); 
                    end)

            end; 

        };

        init = function (self) 

            events.aim_ack:set(
                function () 
                    self.detect_cheatShoot.singe_EventTrigger(); 
                end) 

            events.createmove:set( 
                function (cmd) 
                    self.info:init(cmd); 
                end) 

            events.bullet_impact:set(
                function (arg) 
                    self.info.shoot_manualShootDisableWait(arg); 
                end)
    
            self.events:init(); 

        end; 

    }; 

    ["=>"] = {

        info = function () 
            return FW.localPlayer._.storage.info; 
        end;  

        get_possibleMovingConditions = function () 
            return {"stand", "move", "crouch_move", "crouch", 'air', "air_crouch", "air_steady"} 
        end; 

        get_velocity = function () 
            return entity.get_local_player().m_vecVelocity:length();
        end; 

        is_alive = function () 
            local lp = get_local_player(); 
            if (lp == nil) then return nil; end 
            return lp:is_alive(); 
        end;

    }

};


FW.localPlayer._:init();