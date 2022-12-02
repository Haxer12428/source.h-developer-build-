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
                modifier_inverter = true; 
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

                quick_jitter = false;  

                lagcomp = {
                    enabled = true; 
                    strenght = 4; 
                    lastbreak = vector(0, 0);
                    break_until = 0;  
                    breakevery = 100; 
                }; 

                stop_inverters_till = 0;

                onshot_mode = "Stop"

            }

        }; 

        m_getTarget = {

            getBestFromInfo = function (world, screen) 
                local threat_hittable = get_threat(true); 
                local threat = get_threat(); 


                if (threat_hittable ~= nil) then 
                    local threat_hittable_info = threat_hittable:get_network_state(); 
                    if (threat_hittable_info == 0) then 
                        return threat_hittable; 
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

                local origin = target:get_eye_position();
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

        body_yaw = { 

            modifier = {

                inverter = function (hook, body)
                    local packet = hook.command_number % 2; 
                    
                    if (packet ~= body.realOn or hook.tickcount <= body.stop_inverters_till) then 
                        return end 

                    body.modifier_inverter = FW.math['=>'].opposite_bool(body.modifier_inverter); 
                end; 

                get_animstateOffset = function () 
                    local weight = 0; 
                    local local_player = entity.get_local_player(); 
                    local animstate = local_player:get_anim_state(); 

                    weight = weight + animstate.acceleration_weight;
                    weight = weight + animstate.move_weight;

                    return weight;
                end; 

                set = function (self, hook, body) 
                    local inverter = body.modifier_inverter; 
                    local modifier = body.modifier; 
                    local yaw = body.yaw[inverter]; 
                    local animstate = self.get_animstateOffset(hook); 

                    print(animstate)

                    local angle = (inverter and modifier or -modifier) + yaw + animstate; 

                    hook.view_angles.y = hook.view_angles.y + angle; 
                end; 

                handler = function (self, hook, body) 

                    self:set(hook, body); 
                    self.inverter(hook, body);

                end; 

                init = function (self) 
                    return {
                        hook = self.handler
                    }
                end; 

            };
            
            yawbase = {

                set = function (hook) 
                    local target = FW.angles['=>'].get_targetInfo(); 
                    local angles = target.yaw; 
                    
                    if (target.entity == nil) then 
                        angles = render.camera_angles().y; end 

                    hook.view_angles.y = angles; 
                    hook.view_angles.x = 89.90;
                end; 

                init = function (self) 
                    return {
                        hook = self.set; 
                    }
                end; 

            }; 

            desync = {

                can_enable = function () 
                    local local_player = entity.get_local_player(); 
                    local weap = local_player:get_player_weapon(); 
                    if (weap == nil) then 
                        return false; end 

                    local weap_info = weap:get_weapon_info(); 
                    if (weap_info.is_revolver) then 
                        return false; end 

                    return true; 
                end; 

                inverter = function (body, hook) 
                    local packet = hook.command_number % 2; 

                    if (packet ~= body.realOn or hook.tickcount <= body.stop_inverters_till) then 
                        return end 

                    body.inverter = FW.math['=>'].opposite_bool(body.inverter); 
                end; 

                get_finalDesyncAngle = function (body) 
                    local inverter = body.inverter; 
                    local desync = 50 - body.desync[body.modifier_inverter]; 
                    local desync_add = body.body_yaw_add[inverter]; 
                    
                    if (desync < 0) then desync = inverter and -math.abs(desync) or math.abs(desync) end 

                    local angle = inverter and -desync or desync; 
                    angle = angle + desync_add/2

                    return angle*2; 
                end; 

                update_info = function (self, body, hook)
                    local angle = self.get_finalDesyncAngle(body); 

                    body.current_desync = angle; 
                    body.maximum_desync = math.max(math.abs(angle), body.maximum_desync);
                end; 

                set = function (self, body, hook) 
                    local packet = hook.command_number % 2; 

                    if (packet == body.realOn) then 
                        return end 

                    local angle = self.get_finalDesyncAngle(body); 
                    
                    if (not self.can_enable()) then 
                        hook.send_packet = false; return end 

                    local inverter = body.inverter; 

                    print(inverter)

                    hook.view_angles.y = hook.view_angles.y + angle; 
                    hook.send_packet = false; 
                end; 

                handler = function (self, hook, body) 
                    self.inverter(body, hook); 
                    self:update_info(body, hook); 
                    self:set(body, hook); 
                end; 

                init = function (self) 
                    return {
                        hook = self.handler
                    }
                end; 

            };  

            exploits = {

                quick_jitter = function (hook, body) 
                    local desync = body.desync[body.inverter]; 

                    if (not body.quick_jitter or desync < 48) then 
                        return end 

                    local rand = hook.tickcount % 4
                    if (rand ~= 1) then 
                        return end 
                    
                    body.realOn = hook.command_number % 2; 
                end; 

                break_lagcomp = function (hook, body) 
                    local table = body.lagcomp; 
                    
                    if (not table.enabled) then 
                        return end 

                    local last_break = table.lastbreak; 
                    local current_vector = entity.get_local_player():get_origin(); 

                    if (globals.tickcount <= table.break_until) then 
                        table.lastbreak = current_vector; 
                        hook.force_defensive = true; end 

                    if (globals.tickcount + 100 <= table.break_until) then 
                        table.break_until = 0; end 

                    if (last_break:dist(current_vector) > table.breakevery) then 
                        table.break_until = globals.tickcount + table.strenght; end 
                end; 

                stop_inverters = function (body) 
                    local rand = utils.random_int(1, 30); 

                    if (rand ~= 1) then 
                        body.stop_inverters = false; 
                        return end 

                    body.stop_inverters = true; 
                end; 

                handler = function (self, hook, body) 
                    self.quick_jitter(hook, body);
                    self.break_lagcomp(hook, body);
                end; 

                init = function (self) 
                    return {
                        hook = self.handler
                    }
                end; 

            }; 

            post_handlers = {   

                trigger_onshot = function (body) 
                    local onshot_time = 2;
                    body.onshot_till = globals.tickcount + onshot_time; 
                end;

                handle_onshot = function (hook, body) 
                    if (body.onshot_till - 15 > hook.tickcount) then 
                        body.onshot_till = 0; return end 

                    if (body.onshot_till < hook.tickcount) then 
                        return end 
                        
                    local modes = {

                        Stop = function () 
                            body.stop_inverters_till = body.onshot_till;
                            print("Under onshot!");
                        end;

                    }; 
                    modes[body.onshot_mode](); 
                end;

                run_handler = function (self, body) 
                    events.cheat_shoot:set(
                        function ()
                            self.trigger_onshot(body); 
                        end)
                end; 

                hook_handler = function (self, hook, body) 
                    self.handle_onshot(hook, body)
                end; 

                init = function (self) 
                    return {
                        hook = function (hook, body) self:hook_handler(hook, body) end;
                        _G = function (body) self:run_handler(body); end 
                    }
                end;
            }; 

            main = {

                check_sanity = function () 
                    local player_info = FW.localPlayer['=>'].info(); 
                    
                    if (player_info.manual_preShoot) then return false; end 

                    if (player_info.nade_throwWait) then return false; end 

                    if (player_info.on_ladder) then return false; end 

                    if (player_info.on_use) then return false; end 

                    if (not FW.game['=>'].get_info().round_started) then return false; end 

                    return true; 
                end;

                init = function (self, body) 
                    local storage = FW.angles._.storage.fakeangle; 
                    local modifier = body.modifier:init(); 
                    local yawbase = body.yawbase:init(); 
                    local desync = body.desync:init(); 
                    local exploits = body.exploits:init(); 
                    local handlers = body.post_handlers:init(); 

                    handlers._G(storage); 

                    events.createmove:set(
                        function (hook)
                            if (not self.check_sanity()) then 
                                return end 

                            desync.hook(body.desync, hook, storage);

                            yawbase.hook(hook); 
                            
                            exploits.hook(body.exploits, hook, storage)

                            modifier.hook(body.modifier, hook, storage); 
                            desync.hook(body.desync, hook, storage);

                            events.antiaim_afterUpdate:call(hook);
                            
                            handlers.hook(hook, storage); 

                        end)

                end; 

            }

        };

        init = function (self)

            self.body_yaw.main:init(self.body_yaw); 

            events.createmove:set( 
                function (cmd) 
                    self.m_getTarget:main(cmd);
                end);

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
        end; 

        configure_breakLagComp = function (enable, strength, distance)
            local lagcomp = FW.angles._.storage.fakeangle.lagcomp; 
            lagcomp.strenght = strength; 
            lagcomp.enabled = enable; 
            lagcomp.breakevery = distance; 
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
