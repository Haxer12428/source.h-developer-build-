FW.angles = { 

    _ = { 
        storage = {

            target = {
                entity = nil; 
                yaw = 0; 
            }; 

            fakeangle = {

                realOn = 0; 
                modifier = 45/2; 
                randomization = 120; 
                desync_randomization = 0; 
                pitch = 89.96; 
                inverter = true; 
                jitter_speed = 4; 

                yaw = {

                    [false] = 0;
                    [true] = 19; 

                }; 

                desync = {

                    [false] = 55; 
                    [true] = 55; 

                }; 

                body_yaw_add = { 

                    [false] = 5; 
                    [true] = -5; 

                }; 

                on_shot = "opposite-state"; 
                final_desync = 0; 

                lastRealOn = 0; 

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

                if (random == 1) then 
                    return end 
                
                if (2 < cmd.choked_commands) then 
                    packet = 10; end 

                if (packet == invert) then 
                    return end 

                FW.angles._.storage.fakeangle.inverter = FW.math["=>"].opposite_bool(FW.angles._.storage.fakeangle.inverter);
                FW.angles._.storage.fakeangle.lastRealOn = FW.angles._.storage.fakeangle.realOn; 
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
                --FW.angles._.storage.fakeangle.randomization = utils.random_int(128, 130);
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

local new = ui.create("Body Yaw"); 
local storage = FW.angles._.storage.fakeangle

local modifier = new:slider("Offset | Modifier", -180, 180, 0); 
local yaw_left = new:slider("Offset | Left", -60, 60, 0); 
local yaw_right = new:slider("Offset | Right", -60, 60, 0); 

local body_yaw_add_left = new:slider("Body Yaw | Add Left", -60, 60, 0); 
local body_yaw_add_right = new:slider("Body Yaw | Add Right", -60, 60, 0);  

local desync_left = new:slider("Body Yaw | Left Limit", 0, 60, 60); 
local desync_right = new:slider("Body Yaw | Right Limit", 0, 60, 60); 

local randomization = new:slider("Body Yaw | Randomization", 0, 500, 120); 

events.runtime:set(
    function() 
        storage.body_yaw_add[false] = body_yaw_add_left:get();
        storage.body_yaw_add[true] = body_yaw_add_right:get();

        storage.modifier = modifier:get()/2; 
        storage.yaw[false] = yaw_left:get();
        storage.yaw[true] = yaw_right:get(); 

        storage.desync[false] = desync_left:get();
        storage.desync[true] = desync_right:get(); 

        storage.randomization = randomization:get();

    end)


FW.angles._:init(); 