FW._G = {

    _ = {

        loop_infRuntime = { 
            _ = {
                timer = 0.02; 
            }; 

            loopback = function (self) 

                execute_after(self._.timer, 
                    function() 
                        events.runtime:call(); 
                    end)

            end; 

        }; 

        init = function (self) 

            events.runtime:set(
                function () 
                    self.loop_infRuntime:loopback(); 
                end); 

            events.runtime:call();
        end; 

    }; 

    ["=>"] = { 

        get_memory_usage = function ()  
            return memInfo()/1024 .. "mb"; 
        end; 

        get_delayed_ticks = function () 
            local net_channel = get_net_channel(); 
            if (net_channel == nil) then return 0; end 
            local ping = tonumber( string.format('%.4f', net_channel.latency[1] ));
            return 64*(ping*2);
        end; 

    }


}; 


FW._G._:init(); 

events.render:set(function () 

    render.text(

        3,
        vector(10, 10),
        color(255, 255, 0, 255),
        nil, 
        FW._G["=>"].get_memory_usage()

    )

end); 