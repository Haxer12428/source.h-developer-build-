FW.animate = {

    _ = { 

        storage = {}

    };

    ['=>'] = {
       
        basic = function (self, name, speed, start, dest)
            local cache = FW.animate._.storage; 

            if ( cache[name] == nil ) then 
                cache[name] = {
                    value = start, 
                    updated = globals.realtime; 
                }; end 

            local delta = globals.realtime - cache[name].updated; 
            cache[name].updated = globals.realtime;
            
            if ( cache[name].value < dest ) then 
                cache[name].value = math.min(dest, (cache[name].value + delta*speed)); end 

            if ( cache[name].value > dest ) then 
                cache[name].value = math.max(dest, (cache[name].value - delta*speed)); end 

            return cache[name].value 
        end

    }

}