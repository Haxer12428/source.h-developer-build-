global.antiaim = {

    _ = {

        storage = {

            antibruteforce = {
                global_enabled = true; 

                enabled = false; 
                timer = 0; 
                reset_after = 4; 
                attacker = nil;
                missed_conditions = {}; 

                --//modes
                side_mode = "Missed Side";
                desync_mode = "Default";
            }; 

        };

        get = {

            body_yawMode = function (mode, l, r, cmd)
                local modes = {
                    ["Statical"] = function () 
                        return {l = l, r = r}; 
                    end;  

                    ["Jitter"] = function () 
                        local time = (globals.realtime*60) % 2 
                        return {l = l*time, r = r*time}; 
                    end; 

                    ["Swapping"] = function () 
                        local swap = utils.random_int(0, 1);
                        if (swap == 0) then 
                            return {l = l, r = r}; end 
                        return {l = 0, r = 0};
                    end; 

                    ["Random"] = function ()
                        return {l = utils.random_int(0, l), r = utils.random_int(0, r)};
                    end
                }
                return modes[mode]();
            end; 

            body_mode = function (mode, l, r, cmd) 
                local modes = {
                    ['Default'] = function () 
                        return {l = l, r = r}; 
                    end;

                    ["Priority"] = function () 
                        if (cmd.sidemove > 0) then 
                            return {l = 60, r = r}; end 
                        if (cmd.sidemove < 0) then 
                            return {l = r, r = 60}; end 
                        return {l = l, r = r}; 
                    end; 
                }; 

                return modes[mode](); 
            end; 

            yaw_randomizationModes = function (mode, speed, limit) 
                local modes = {
                    ["5-Way"] = function ()
                        local timecount = tonumber(string.format("%.0f", (globals.realtime*speed % 4))) + 1;

                        local offsets = {
                            -limit/4,
                            limit/2,
                            limit/3, 
                            -limit/1.5,
                            -limit
                        }; 
                        return offsets[timecount];
                    end; 
                }
                return modes[mode]();
            end; 

            antibruteforce_limits = function () 
                local player_info = FW.localPlayer['=>'].info(); 
                local move_state = player_info.move_state; 

                local antibruteforce = global.antiaim._.storage.antibruteforce; 
                
                if (not antibruteforce.enabled) then 
                    return nil end 

                local missed_condition = antibruteforce.missed_conditions[move_state]; 

                if (missed_condition == nil) then 
                    return nil; end 

                local count = missed_condition.count; 
                local angle = missed_condition.angle; 

                if (count == nil or angle == nil) then 
                    return nil; end 

                if (angle.l < 0) then 
                    angle.l = math.abs(angle.l); end 

                if (angle.r < 0) then 
                    angle.r = math.abs(angle.r); end 

                return angle; 
            end; 

        }; 

        modules = {
            
            antibruteforce = {

                phase_algorithm = function (args, side, side_mode, desync_mode, non_usedDelta) 
                    local distance = math.min(60, 60 - (math.abs(args.closest_distanceDefault) / (args.distance_toPass/60))); 

                    local side_modes = {
                        ['Opposite Side'] = function (v) 
                            return side and -v or v; 
                        end; 

                        ["Missed Side"] = function (v)
                            return side and v or -v; 
                        end
                    }; 

                    local desync_modes = {
                        ["Default"] = function (v) 
                            return v; 
                        end; 

                        ["Low Randomized"] = function (v) 
                            return math.min(60, v/2 + utils.random_int(-5, 5));
                        end;  

                        ["Randomized"] = function (v) 
                            return math.min(60, v + math.random(-15, 15)); 
                        end; 
                    }; 

                    local final_angle = desync_modes[desync_mode](distance); 
                    local final_sidedAngle = math.max(-60, math.min(60, side_modes[side_mode](final_angle))); 

                    if (final_sidedAngle > 0) then 
                        return {l = non_usedDelta, r = final_sidedAngle}; end 

                    return {l = final_sidedAngle, r = non_usedDelta}; 
                end; 

                reset = function () 
                    local storage = global.antiaim._.storage.antibruteforce;  

                    local erease = function (reason) 
                        storage.attacker = nil; 
                        storage.missed_conditions = {}; 
                        storage.enabled = false; 

                        local args = {
                            reason = reason; 
                        }

                        events.antibruteforce_reset:call(args);
                    end; 

                    if (not storage.enabled) then 
                        return end 

                    if (storage.attacker == nil) then 
                        erease("No attacker"); return end 

                    if (storage.timer < globals.realtime) then 
                        erease("Timed out"); return end 

                    if (not storage.attacker:is_alive()) then 
                        erease("Attacker is dead"); return end 

                    if (not storage.attacker:is_enemy()) then 
                        erease("Attacker error"); return end 

                    if (not get_local_player():is_alive()) then
                        erease("LocalPlayer is dead"); return end 
                    

                end; 

                main = function (self, args) 
                    local player_info = FW.localPlayer['=>'].info(); 
                    local move_state = player_info.move_state; 
                    local current_side = FW.angles['=>'].get_inverter(); 
                    local storage = global.antiaim._.storage.antibruteforce; 

                    if (not storage.global_enabled) then 
                        return end 

                    local attacker = args.attacker; 
                    local desync_angle = self.phase_algorithm(args, current_side, storage.side_mode, storage.desync_mode, 58); 

                    storage.enabled = true; 
                    storage.attacker = attacker; 
                    storage.timer = globals.realtime + storage.reset_after; 

                    if (storage.missed_conditions[move_state] == nil) then 
                        storage.missed_conditions[move_state] = {count = 0, angle = 0}; end 

                    storage.missed_conditions[move_state].count = storage.missed_conditions[move_state].count + 1; 
                    storage.missed_conditions[move_state].angle = desync_angle; 
                    
                    local args = {
                        
                    }

                    events.antibruteforce_switch:call(args);
                end; 

            }; 

            antiaim_options = {

                prevent_jitter = function (table) 
                    local target = FW.angles["=>"].get_target(); 

                    local prevent_conditions = {

                        ["No Target"] = function () 
                            if (target == nil) then 
                                return true; end 
                            return false; 
                        end; 

                        ["Target Dormant"] = function () 
                            if (target == nil) then
                                return false; end 
                            
                            local target_networkState = target:get_network_state(); 

                            if (target_networkState == 2) then 
                                return true; end 
                            if (target_networkState == 4) then
                                return true; end 
                            if (target_networkState == 5) then 
                                return true; end 
                            return false;  
                        end;

                    }; 

                    for _, con in pairs(table) do 
                        if (prevent_conditions[con] ~= nil) then 
                            if (prevent_conditions[con]()) then 
                                return true; end 
                        end; end 

                    return false; 
                end; 

            };

            maximum_backtrackTime = {
                break_until = 0; 
                last_break = 0; 

                break_bt = function (self, cmd) 
                    if (self.break_until >= globals.tickcount) then 
                        print('breakin g')
                        cmd.force_defensive = true; end 

                    local strenght = 2; 
                    local minimal_to_trigger = 100; 
                    local target = FW.angles['=>'].get_target(); 

                    if (target == nil) then 
                        return end 

                    local target_bt = FW.entity['=>']:get_maximumBacktrackTime(target); 

                    if (target_bt < minimal_to_trigger) then
                        return end 

                    if (self.last_break + target_bt*0.01 > globals.realtime) then 
                        return end 
                        
                    self.last_break = globals.realtime; 
                    self.break_until = globals.tickcount + strenght; 
                end; 

                handler = function (self) 
                    if (self.break_until - 100 > globals.tickcount) then 
                        self.break_until = 0; end 
                end;  

                init = function (self, cmd) 
                    self:handler(); 
                    self:break_bt(cmd); 
                end; 

            }; 

            init = function (self) 

                events.missed_local:set(
                    function (...) 
                        self.antibruteforce:main(...);
                    end)  

                events.createmove:set(
                    function (cmd) 
                        self.antibruteforce.reset();
                        --self.maximum_backtrackTime:init(cmd); 
                    end)

            end; 

        }; 

        set = {

            config = function () 
                FW.angles['=>'].set_inverter_speed(4); 
            end; 

            builder = function (cmd) 
                local player_info = FW.localPlayer["=>"].info();  
                local move_state = player_info.move_state; 
                local menu_elements = global.menu["=>"].get_elements(); 

                if (move_state == nil) then return end 

                local main_condition = move_state; 
                local overrided = menu_elements[move_state.."override"]:get(); 
                local inverter = FW.angles["=>"].get_inverter(); 

                if (not overrided) then 
                    main_condition = "global"; end 

                local modifier_left = menu_elements[move_state.."modifier_degreeLeft"]:get(); 
                local modifier_right = menu_elements[move_state.."modifier_degreeRight"]:get(); 
                local modifier = inverter and modifier_right or modifier_left; 

                local body_addLeft = menu_elements[move_state.."bodyyaw_addLeft"]:get(); 
                local body_addRight = menu_elements[move_state.."bodyyaw_addRight"]:get(); 
                local body_addMode = menu_elements[move_state.."bodyyaw_addMode"]:get();  

                local body_add = global.antiaim._.get.body_yawMode(body_addMode, body_addLeft, body_addRight, cmd); 

                local fake_limitLeft = menu_elements[move_state.."bodyyaw_limitLeft"]:get(); 
                local fake_limitRight = menu_elements[move_state.."bodyyaw_limitRight"]:get(); 
                local fake_limitMode = menu_elements[move_state.."bodyyaw_mode"]:get(); 
                local final_fakeLimits = global.antiaim._.get.body_mode(fake_limitMode, fake_limitLeft, fake_limitRight, cmd); 

                local stop_offset = menu_elements[move_state.."stopoffsetenable"]:get(); 
                local stop_offset_amount = stop_offset and menu_elements[move_state.."stopoffsetamount"]:get() or 0; 

                local global_yaw = menu_elements[move_state.."yaw_degree"]:get(); 
                local yaw_randomization = menu_elements[move_state.."yaw_randomization_enable"]:get(); 
                local yaw_randomization_mode = menu_elements[move_state.."yaw_randomization_mode"]:get();
                local yaw_randomization_limit = menu_elements[move_state.."yaw_randomization_limit"]:get(); 

                if (yaw_randomization) then 
                    global_yaw = global_yaw + global.antiaim._.get.yaw_randomizationModes(yaw_randomization_mode, 3, yaw_randomization_limit); end 

                FW.angles['=>'].override_yaw(global_yaw, global_yaw);
                FW.angles["=>"].override_bodyYawLimits(final_fakeLimits.l, final_fakeLimits.r);
                FW.angles["=>"].override_bodyYawOffsets(body_add.l, body_add.r); 
                FW.angles["=>"].override_modifier(modifier);
                FW.angles["=>"].override_offsetStopTimer(stop_offset_amount);
            end; 

            antibruteforce = function () 
                local limits = global.antiaim._.get.antibruteforce_limits(); 

                if (limits == nil) then 
                    return end 

                local mode = global.menu['=>'].get_elements().antibruteforce_desync_mode:get(); 

                if (mode == "Limit") then 
                    FW.angles["=>"].override_bodyYawLimits(limits.l, limits.r);
                    FW.angles['=>'].override_bodyYawOffsets(0, 0); 
                    return end 
                
                FW.angles["=>"].override_bodyYawLimits(60, 60);
                FW.angles['=>'].override_bodyYawOffsets(-(60 - limits.l), (60 - limits.r));                 
            end; 
            
            antibruteforce_config = function () 
                local storage = global.antiaim._.storage.antibruteforce; 
                
                storage.side_mode = global.menu._.elements.antibruteforce_algorithm_side:get(); 
                storage.desync_mode = global.menu._.elements.antibruteforce_algorithm_desync:get(); 
                storage.global_enabled = global.menu._.elements.antibruteforce_enable:get();
            end;  

            on_resolveActions = function (perform) 
                local target = FW.angles['=>'].get_targetInfo(); 
                if (target.resolved_by ~= true) then 
                    return end 
                
                if (target.resolved_moveState ~= FW.localPlayer['=>'].info().move_state) then 
                    return end 

                local actions = {
                    ["Lock Desync"] = function () 
                        local r = target.resolved_side == true and utils.random_int(20, 60) or nil; 
                        local l = target.resolved_side == false and utils.random_int(20, 60) or nil; 
                        FW.angles['=>'].override_bodyYawLimits(l, r); 
                    end; 
                }

                for _, action in pairs(perform) do 
                    actions[action](); end; 
            end; 

            antiaim_options = function (self) 
                local prevent_jitterSelected = global.menu._.elements.prevent_jitter_options:get(); 
                if (type(prevent_jitterSelected) == "string" ) then prevent_jitterSelected = {prevent_jitterSelected}; end 
                local should_disableJitter = global.antiaim._.modules.antiaim_options.prevent_jitter(prevent_jitterSelected); 

                if (should_disableJitter) then 
                    FW.angles['=>'].slow_inverter(); end 

                self.on_resolveActions(global.menu['=>'].get_elements().on_resolve_actions:get()); 
            end;  

        }; 

        init = function (self) 

            events.antiaim_afterUpdate:set(
                function (cmd) 
                    self.set.config(); 
                    self.set.builder(cmd);
                    self.set:antiaim_options(); 
                    self.set.antibruteforce(); 
                end)

            self.modules:init(); 

            events.runtime:set(
                function () 
                    self.set.antibruteforce_config(); 
                end)

        end
    };

    ['=>'] = {

        get_antibruteforceTimeLeft = function () 
            return math.max(0, global.antiaim._.storage.antibruteforce.timer - globals.realtime); 
        end;

        get_antibruteforceInfo = function (name)
            if (name == nil) then 
                return global.antiaim._.storage.antibruteforce; end  
            return global.antiaim._.storage.antibruteforce[name]; 
        end;

    }

}

global.antiaim._:init();  
