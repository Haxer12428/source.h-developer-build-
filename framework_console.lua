FW.console = {

    ["=>"] = {

        color_print = function (colors, endl, ...) 
            local ffi = FW.ffi["=>"].get(); 

            local defaultColor, mainColor = colors[1], colors[2]; 
            local arguments = {...}; 

            if (type(...) == "table") then 
                arguments = ...; end   

            for _, argument in pairs(arguments) do 
                local color_c = defaultColor; 

                if (string.match(argument, "&&")) then 
                    color_c = mainColor; argument = argument:gsub("&&", ""); end 

                ffi.colorPrintFunction(ffi.colorPrintInterface, ffi.color_struct_t(color_c.r, color_c.g, color_c.b, color_c.a), argument); 
            end

            if (endl) then 
                print_raw(""); end 
        end; 

    }

}