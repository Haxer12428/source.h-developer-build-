FW.angles = { 

    _ = { 
        storage = {

            targets_data = {}; 

            target = {
                entity = nil; 
                yaw = 0; 
                resolved_by = false; 
                resolved_side = nil; 
                resolved_moveState = nil; 
            }; 

            fakeangle = {

                realOn = 0; 
                modifier = 0; 
                randomization = 0; 
                desync_randomization = 0; 
                pitch = 89.98; 
                inverter = true; 
                jitter_speed = 4; 
                
                packet = 0; 

                yaw = {

                    [false] = 0;
                    [true] = 0; 

                }; 

                desync = {

                    [false] = 60; 
                    [true] = 60; 

                }; 

                body_yaw_add = { 

                    [false] = 0; 
                    [true] = 0; 

                }; 

                on_shot = "opposite-state"; 
                final_desync = 0; 

                lastRealOn = 0;  

                maximum_desync = 0; 
                current_desync = 0;  

                onshot_till = 0; 

            }

        }; 

        m_getTarget = {

            getBestFromInfo = function (world, screen) 
                local threat_hittable = get_threat(true); 
                local threat = get_threat(); 


                if (threat_hittable ~= nil) then 
                    local threat_hittable_info = threat_hittable:get_network_state(); 
                    if (threat_hittable_info == 0) then 
                        return threat; 
                    end; end 

                if ( screen.closest_enemy == nil ) then 

                    if ( world.closest_enemy == nil and world.dormant_closest_enemy == nil ) then 
                        return threat; end; 
                        
                    if (world.closest_enemy ~= nil) then 
                        return world.closest_enemy; end 

                    if (world.dormant_closest_enemy ~= nil) then 
                        return world.dormant_closest_enemy; end 

                end; 

                if (world.closest_distance < 40) then 
                    return world.closest_enemy; end 

                if (world.closest_enemy == screen.closest_enemy) then 
                    return world.closest_enemy; end 

                if (world.dormant_closest_enemy == screen.closest_enemy) then 
                    return world.dormant_closest_enemy; end 

                return screen.closest_enemy; 
            end; 

            getYawToTarget = function (target)
                if (target == nil) then
                    return render.camera_angles().y; end 

                local origin = target:get_origin();
                local my_origin = get_local_player():get_origin();

                return FW.math["=>"].angle_between2Vectors(my_origin, origin);
            end; 

            findBest = function (self) 
                local active_enemies = FW.entity["=>"].get_activeEnemies(true); 
                local local_player = entity.get_local_player(); 
                local local_origin = local_player:get_origin(); 

                local camera_position = render.camera_position(); 
                local camera_angles = render.camera_angles(); 
                local camera_angles_forward = vector():angles(camera_angles); 

                local screen = {
                    closest_distance = math.huge; 
                    closest_enemy = nil; };

                local world = {
                    closest_distance = math.huge; 
                    closest_enemy = nil; 
                    
                    dormant_closest_distance = math.huge; 
                    dormant_closest_enemy = nil; 
                }

                for _, enemy in pairs(active_enemies) do 
                    local origin = enemy:get_hitbox_position(3); 
                    
                    local ray_distance = origin:dist_to_ray(
                        camera_position, camera_angles_forward);
                    
                    if (ray_distance < screen.closest_distance) then 
                        screen.closest_enemy = enemy;
                        screen.closest_distance = ray_distance; end 

                    local world_distance = local_origin:dist(origin); 

                    if (world_distance < world.closest_distance and not enemy:is_dormant()) then 
                        world.closest_enemy = enemy; 
                        world.closest_distance = world_distance; end 

                    if (world_distance < world.dormant_closest_distance and enemy:is_dormant()) then 
                        world.dormant_closest_enemy = enemy; 
                        world.dormant_closest_distance = world_distance; end 

                end

                local best_targetFound = self.getBestFromInfo(world, screen);  
                return best_targetFound; 
            end; 

            is_resolvedByTarget = function (target) 
                if (target == nil or target:get_xuid() == nil) then 
                    return {false, nil, nil}; end 
                if (FW.angles._.storage.targets_data[target:get_xuid()] == nil) then 
                    return {false, nil, nil}; end 
                if (FW.angles._.storage.targets_data[target:get_xuid()].state ~= true) then 
                    return {false, nil, nil}; end 
                return {
                    true; FW.angles._.storage.targets_data[target:get_xuid()].side, FW.angles._.storage.targets_data[target:get_xuid()].move_state
                }; 
            end; 

            handle_onResolve = function (args)
                if (not args.headshoted) then 
                    return end 

                FW.angles._.storage.targets_data[args.attacker:get_xuid()] = {
                    state = true; side = args.side, move_state = args.move_state };  
            end;  
            
            handle_onMiss = function (args)
                FW.angles._.storage.targets_data[args.attacker:get_xuid()] = {
                    state = false; side = nil, move_state = nil };  
            end; 
            
            main = function (self, cmd)
                local found = self:findBest(); 
                local yaw = self.getYawToTarget(found); 
                local is_resolved = self.is_resolvedByTarget(found);
                
                FW.angles._.storage.target = {
                    entity = found; 
                    yaw = yaw; 
                    resolved_by = is_resolved[1];
                    resolved_side = is_resolved[2];  
                    resolved_moveState = is_resolved[3];
                }
            end; 

        }; 

        m_fakeAngle = {

            inverter = function (cmd) 
                local invert = FW.angles._.storage.fakeangle.realOn; 
                local jitter_speed = (10 - FW.angles._.storage.fakeangle.jitter_speed*2); 

                if (jitter_speed < 0) then jitter_speed = math.abs(jitter_speed); end 

                local packet = cmd.command_number % jitter_speed; 
                local random = cmd.command_number % FW.angles._.storage.fakeangle.randomization; 

                if (random == 1 or random == 0) then 
                    FW.angles._.storage.fakeangle.realOn = FW.math['=>'].opposite1BitInt(FW.angles._.storage.fakeangle.realOn); end 

                if (FW.angles._.storage.fakeangle.last_switch == cmd.command_number) then 
                    return end 

                if (packet == FW.math['=>'].opposite1BitInt(invert) or cmd.choked_commands > 1) then 
                    return end 

                FW.angles._.storage.fakeangle.last_switch = cmd.command_number; 
                FW.angles._.storage.fakeangle.inverter = FW.math["=>"].opposite_bool(FW.angles._.storage.fakeangle.inverter);
                --FW.angles._.storage.fakeangle.lastRealOn = FW.angles._.storage.fakeangle.realOn; 
            end;   

            setDefaultAngles = function () 
                local list = FW.GameVars['=>'].get_list(); 
                local round_started = FW.game['=>'].get_varByName("round_started"); 
                local fakeangle = FW.angles._.storage.fakeangle; 

                local YAWMODE = round_started and "Backward" or "Disabled";  

                --//FREESTAND (pseudo fix)  
                if (FW.GameVars['=>'].get_var("FREESTAND", true) and round_started) then 
                    
                    list.BODYYAW:set(true); 
                    list.PITCH:set("Down");
                    list.YAWBASE:set("At Target");
                    list.YAWMODE:set("Backward");
                    list.MODIFIER:set("Center");
                    list.MODIFIEROFFSET:set(-fakeangle.modifier*2);

                    return; end 

                list.BODYYAW:set(false);
                list.MODIFIER:set("Disabled");
                list.PITCH:set("Down");
                list.YAWBASE:set("Local View");
                list.YAWMODE:set(YAWMODE);
                list.YAWOFFSET:set(0);
                list.MODIFIEROFFSET:set(0);

            end; 

            getDesyncAngle = function (cmd) 
                local fakeangle = FW.angles._.storage.fakeangle; 

                local inverter = fakeangle.inverter; 

                if (inverter == nil) then return {desynced = 0; real = 0;}; end 

                local ds = fakeangle.desync[inverter]; 

                local offset = 60 - ds;  
                offset = inverter and -offset or offset;  

                local realoffset = (60 - ds);
                realoffset = inverter and -realoffset or realoffset;  

                offset = offset + fakeangle.body_yaw_add[inverter];

                if (math.abs(offset) > fakeangle.maximum_desync) then 
                    fakeangle.maximum_desync = math.abs(offset); end 
                
                fakeangle.current_desync = math.abs(offset); 

                return { 
                    desynced = offset/2; 
                    real = realoffset/2; 
                }
            end; 

            getFinalAngle = function (self, cmd) 
                local fakeangle = FW.angles._.storage.fakeangle; 

                local inverter = fakeangle.inverter; 
                local modifier = fakeangle.modifier; 
                local packet = cmd.command_number % 2;  

                local final_angle = inverter and modifier or -modifier; 

                local desync_offsets = self.getDesyncAngle(cmd); 
                FW.angles._.storage.fakeangle.final_desync = desync_offsets.desynced*2;

                
                local weap = entity.get_local_player():get_player_weapon(); 

                if (packet ~= fakeangle.realOn and weap ~= nil and not weap:get_weapon_info().is_revolver) then 
                    final_angle = final_angle + desync_offsets.desynced; else final_angle = final_angle - desync_offsets.real; end 

                if (quick_jitter) then 
                    final_angle =( inverter and modifier or -modifier)- desync_offsets.real; end 

                return {
                    angle = FW.angles._.storage.target.yaw + final_angle + fakeangle.yaw[inverter];
                    quick_jitter = quick_jitter; 
                }
            end; 

            canEnableAngles = function () 
                local playerInfo = FW.localPlayer["=>"].info(); 
                
                if (playerInfo.nade_throwWait) then 
                    return false; end 
                if (playerInfo.manual_preShoot) then 
                    return false; end 
                if (playerInfo.on_ladder) then 
                    return false; end 
                if (playerInfo.on_use) then 
                    return false; end 
                if (not FW.game['=>'].get_varByName('round_started')) then 
                    return false; end 
                if (FW.GameVars["=>"].get_var("FREESTAND", true)) then 
                    return false; end 
                return true; 
            end; 

            applyAngles = function (self, cmd) 
                if (not self.canEnableAngles()) then 
                    return end 

                local finalAngle = self:getFinalAngle(cmd); 
                local real_on = FW.angles._.storage.fakeangle.realOn;  
                
                local packet = cmd.command_number % 2; 
                FW.angles._.storage.fakeangle.packet = packet; 
            
                cmd.view_angles.x = FW.angles._.storage.fakeangle.pitch; 

                if (packet == real_on) then 
                    cmd.view_angles.y = finalAngle.angle; 
                    return 
                end; 
                    
                cmd.send_packet = false;  
                cmd.view_angles.y = finalAngle.angle; 
            end;  

            changeUpdateEveryRound = function () 
                --FW.angles._.storage.fakeangle.randomization = utils.random_int(128, 130);
                FW.angles._.storage.fakeangle.realOn = FW.math["=>"].opposite1BitInt(FW.angles._.storage.fakeangle.realOn);
                FW.angles._.storage.fakeangle.inverter = FW.math["=>"].opposite_bool(FW.angles._.storage.fakeangle.inverter); 
            end;   

            handle_onshot = function () 
                local fakeangle = FW.angles._.storage.fakeangle; 

                if (fakeangle.onshot_till - 100 > globals.tickcount) then 
                    fakeangle.onshot_till = 0;
                    return end 

                if (fakeangle.onshot_till < globals.tickcount) then 
                    return end 

                if (FW.GameVars["=>"]:get_enabledExploit() == "HS") then 
                    return end 

                fakeangle.jitter_speed = 1; 
                fakeangle.yaw[false] = utils.random_int(-20, 20); 
                fakeangle.yaw[true] = utils.random_int(-20, 20); 
                fakeangle.desync[false] = utils.random_int(0, 90); 
                fakeangle.desync[true] = utils.random_int(0, 80);
            end; 

        };

        init = function (self)

            events.createmove:set( 
                function (cmd) 
                    self.m_fakeAngle.setDefaultAngles(); 
                    self.m_getTarget:main(cmd); 
                    self.m_fakeAngle:applyAngles(cmd); 
                    self.m_fakeAngle.inverter(cmd); 
                    events.antiaim_afterUpdate:call(cmd);
                    self.m_fakeAngle.handle_onshot(cmd); 
                end);

            events.round_prestart:set(
                function () 
                    self.m_fakeAngle.changeUpdateEveryRound(); 
                end)

            events.cheat_shoot:set(
                function () 
                    self.m_fakeAngle.changeUpdateEveryRound(); 
                    FW.angles._.storage.fakeangle.onshot_till = globals.tickcount + 2; 
                end)

            events.local_death:set(
                function (...)
                    self.m_getTarget.handle_onResolve(...); 
                end)

            events.missed_local:set(
                function (...)
                    self.m_getTarget.handle_onMiss(...); 
                end)

        end; 

    }; 

    ["=>"] = {

        get_target = function () 
            return FW.angles._.storage.target.entity; 
        end; 

        get_targetInfo = function () 
            return FW.angles._.storage.target;
        end; 

        get_antiaimInfo = function ()
            return FW.angles._.storage.fakeangle; 
        end;  

        override_bodyYawOffsets = function (left, right)
            FW.angles._.storage.fakeangle.body_yaw_add[false] = left; 
            FW.angles._.storage.fakeangle.body_yaw_add[true] = right; 
        end; 

        override_bodyYawLimits = function (left, right)
            if (left ~= nil) then 
                FW.angles._.storage.fakeangle.desync[false] = left; end 
            if (right ~= nil) then 
                FW.angles._.storage.fakeangle.desync[true] = right; end
        end; 

        override_modifier = function (offset)
            FW.angles._.storage.fakeangle.modifier = offset/2; 
        end; 

        get_inverter = function () 
            return FW.angles._.storage.fakeangle.inverter; 
        end; 

        override_offsetStopTimer = function (amount) 
            FW.angles._.storage.fakeangle.randomization = amount; 
        end;

        slow_inverter = function ()
            FW.angles._.storage.fakeangle.jitter_speed = 90; 
        end;

        set_inverter_speed = function (int) 
            FW.angles._.storage.fakeangle.jitter_speed = int; 
        end; 
        
        override_yaw = function (l, r)
            FW.angles._.storage.fakeangle.yaw[true] = r; 
            FW.angles._.storage.fakeangle.yaw[false] = l; 
        end; 

        get_bodyYawMode = function ()
            local fakeangle = FW.angles._.storage.fakeangle;
            local packet = fakeangle.packet;

            if (packet == fakeangle.realOn) then 
                return "Real"; end 
            return "Desync"; 
        end;

        get_desyncDelta = function () 
            return FW.angles._.storage.fakeangle.current_desync; 
        end; 

        get_maximumDesync = function () 
            return FW.angles._.storage.fakeangle.maximum_desync; 
        end 

    }

}; 

events.player_death:set(function (e)
    local death = entity.get(e.userid, true); 
    if (death ~= entity.get_local_player()) then 
        return end 

    print("=> Died: [state: ", FW.angles['=>'].get_inverter(), ", condition: ", FW.localPlayer['=>'].info().move_state, "]");
end)

FW.angles._:init(); 