FW.fonts = {

    _ = {

        storage = {

            list = {}; 

        }

    }; 

    ["=>"] = {
        
        get = function (name, size, flags) 
            local font = FW.fonts._.storage.list[name];
            if (font == nil) then 
                FW.fonts._.storage.list[name] = {}; end 
                
            local font_object = FW.fonts._.storage.list[name][size]; 
            if (font_object == nil) then 
                FW.fonts._.storage.list[name][size] = {}; end 

            local font_objectFlags = FW.fonts._.storage.list[name][size][flags]; 
            if (font_objectFlags == nil) then
                FW.fonts._.storage.list[name][size][flags] = render.load_font(name, size, flags); end 

            return FW.fonts._.storage.list[name][size][flags]; 
        end; 

    }
}