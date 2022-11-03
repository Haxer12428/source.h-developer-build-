FW.math = {

    ["=>"] = {

        angle_between2Vectors = function(v1, v2)
            local delta_y = v1.y - v2.y
            local delta_x = v1.x - v2.x
        
            local relative_yaw = math.atan(delta_y / delta_x)
            relative_yaw = math.normalize_yaw(relative_yaw * 180 / math.pi)
        
            if delta_x >= 0 then
                relative_yaw = math.normalize_yaw(relative_yaw + 180); end
          
            return relative_yaw;
        end;

        opposite_bool = function (boolean)
            if (boolean == true) then
                return false; end 
            return true; 
        end; 

        opposite1BitInt = function (int)
            if (int == 0) then 
                return 1; end 
            return 0;
        end;

    }

}