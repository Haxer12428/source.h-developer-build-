events.render:set(
    function () 
            
        local start = vector(150, 230); 
        local antiaim_info = FW.angles["=>"].get_antiaimInfo(); 
        

        local lp = entity.get_local_player(); 

        local debug_elements = {

            target = FW.angles["=>"].get_target(); 
            modifier = antiaim_info.modifier; 
            yaw_left = antiaim_info.yaw[false];
            yaw_right = antiaim_info.yaw[true]; 
            desync_left = antiaim_info.desync[false];
            desync_right = antiaim_info.desync[true]; 
            realOn = antiaim_info.realOn;
            stop_offset = antiaim_info.randomization; 
            inverter = antiaim_info.inverter; 
            pitch = antiaim_info.pitch; 
            shoot_delayedTicks = FW._G["=>"].get_delayed_ticks(); 
            final_desync = antiaim_info.final_desync;

        }; 

        local __add = 0; 

        for n, v in pairs(debug_elements) do 

            render.text(

                3,
                start + vector(0, __add),
                color(180, 255, 0, 255),
                nil,
                tostring(n) .. "  =  " .. tostring(v) 

            ); 

            __add = __add + 20; 
        end

    end)

