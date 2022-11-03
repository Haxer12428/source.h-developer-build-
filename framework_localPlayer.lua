FW.localPlayer = {

    _ = { 

        storage = {


            info = {

                nade_preThrow = false; 
                nade_throwWait = false; 

                manual_shoot = false; 
                manual_preShoot = false; 
                manual_shootExploitCharged = 0;  

                on_ladder = false; 
                
                on_use = false; 

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

            init = function (self, cmd) 

                self.nade_throwHandleWait(cmd); 
                self.shoot_manualShootForceWait(); 
                self.on_ladderCheck(); 
                self.on_use(cmd); 

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
    

        end; 

    }; 

    ["=>"] = {

        info = function () 
            return FW.localPlayer._.storage.info; 
        end; 

    }

} 

FW.localPlayer._:init();