FW.angles = { 

    _ = { 
        storage = {

            target = {
                entity = nil; 
                yaw = 0; 
            }; 

            fakeangle = {

                realOn = 0; 
                modifier = 30/2; 
                randomization = 20; 
                desync_randomization = 0; 
                pitch = 89.98; 
                inverter = false; 
                jitter_speed = 4; 

                yaw = {

                    [false] = -17;
                    [true] = 22; 

                }; 

                desync = {

                    [false] = 58; 
                    [true] = 58; 

                }; 

                on_shot = "opposite-state"; 
                final_desync = 0; 

            }

        }; 

        m_getTarget = {

            getBestFromInfo = function (world, screen) 
                local threat_hittable = get_threat(true); 
                local threat = get_threat(); 


                if (threat_hittable ~= nil) then 
                    local threat_hittable_info = threat_hittable:get_network_state(); 
                    if (threat_hittable_info == 0) then 
                        return threat; end; end 

                if ( screen.closest_enemy == nil ) then 

                    if ( world.closest_enemy == nil and world.dormant_closest_enemy == nil ) then 
                        return threat; end; 
                        
                    if (world.closest_enemy ~= nil) then 
                        return world.closest_enemy; end 

                    if (world.dormant_closest_enemy ~= nil) then 
                        return world.dormant_closest_enemy; end 

                end; 

                if (world.closest_distance < 140) then 
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
            
            main = function (self, cmd)
                local found = self:findBest(); 
                local yaw = self.getYawToTarget(found); 
                
                FW.angles._.storage.target = {
                    entity = found; 
                    yaw = yaw; 
                }
            end; 

        }; 

        m_fakeAngle = {

            inverter = function (cmd) 
                local invert = FW.angles._.storage.fakeangle.realOn; 
                local packet = cmd.command_number % (10 - FW.angles._.storage.fakeangle.jitter_speed*2); 
                local random = cmd.command_number % FW.angles._.storage.fakeangle.randomization; 

                
                if (2 < cmd.choked_commands) then 
                    packet = 10; end 

                if (packet == invert) then 
                    return end 

                ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement"):set("Sliding");
                FW.angles._.storage.fakeangle.inverter = FW.math["=>"].opposite_bool(FW.angles._.storage.fakeangle.inverter);
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

                return { 
                    desynced = offset; 
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

                if (packet ~= fakeangle.realOn) then 
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
                return true; 
            end; 

            applyAngles = function (self, cmd) 
                if (not self.canEnableAngles()) then 
                    return end 

                local finalAngle = self:getFinalAngle(cmd); 
                local real_on = FW.angles._.storage.fakeangle.realOn; 
                
                local packet = cmd.command_number % 2; 
            
                cmd.view_angles.x = FW.angles._.storage.fakeangle.pitch; 

                if (packet == real_on) then 
                    cmd.view_angles.y = finalAngle.angle; 
                    return 
                end; 
                    
                cmd.view_angles.y = finalAngle.angle; 

                cmd.send_packet = false;  
            end;  

            changeUpdateEveryRound = function () 
                FW.angles._.storage.fakeangle.randomization = utils.random_int(12, 19);
                FW.angles._.storage.fakeangle.realOn = FW.math["=>"].opposite1BitInt(FW.angles._.storage.fakeangle.realOn);
                FW.angles._.storage.fakeangle.inverter = FW.math["=>"].opposite_bool(FW.angles._.storage.fakeangle.inverter); 
            end;  

        };

        init = function (self)

            events.createmove:set( 
                function (cmd) 
                    self.m_getTarget:main(cmd); 
                    self.m_fakeAngle.inverter(cmd); 
                    self.m_fakeAngle:applyAngles(cmd); 
                end); 

            events.round_prestart:set(
                function () 
                    self.m_fakeAngle.changeUpdateEveryRound(); 
                end)

            events.cheat_shoot:set(
                function () 
                    self.m_fakeAngle.changeUpdateEveryRound(); 
                end)

        end; 

    }; 

    ["=>"] = {

        get_target = function () 
            return FW.angles._.storage.target.entity; 
        end; 

        get_antiaimInfo = function ()
            return FW.angles._.storage.fakeangle; 
        end; 

    }

}; 

FW.angles._:init(); 