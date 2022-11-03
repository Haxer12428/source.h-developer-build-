FW.mouse = {

    ["=>"] = {

        is_inPosition = function (v1, v2) 
            local mouse = ui.get_mouse_position(); 
            if (v1.x <= mouse.x and mouse.x <= v2.x) then 
                if (v1.y <= mouse.y and mouse.y <= v2.y) then 
                    return true; 
                end; end 
            return false; 
        end;  

        from = function (vec)
            local mouse = ui.get_mouse_position(); 
            return vec - mouse; 
        end; 

    }

}