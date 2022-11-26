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

        closest_linePoint = function (p1, v1, v2)

            --// x and y lenght ( ground )
            local _x = v2.x - v1.x; 
            local _y = v2.y - v1.y; 
            local _z = v2.z - v1.z; 
        
            --// x per y 
            local _x_y = _x/_y; 
        
            --// z per y
            local _z_y = _z/_y; 
        
            local best = nil; 
            local closest = math.huge;
        
            for lenght = 1, math.abs( _y ) do 
                
                local l = lenght; 
            
                if ( _y < 0 ) then l = -lenght; end 
        
                local traced_origin = v1 + vector (  l * _x_y, l, l * _z_y );
        
                local distance = p1:dist(traced_origin); 
        
                if ( distance < closest ) then 
        
                    closest = distance; 
                    best = traced_origin; 
        
                end
        
        
            end
        
            return { 
        
                distance = closest; 
                position = best; 
        
            }
            

        end; 

        multiple_TableValues = function (amount, value)
            local tbl = {}; 
            for len = 1, amount do 
                tbl[#tbl+1] = value; end 
            return tbl; 
        end; 

        table_toListedString = function (tbl)
            local str = ''; 
            for _, to_list in pairs(tbl) do 
                str = str .. tostring(to_list) .. ", "; end 
            return str:sub(1, -3); 
        end;

        values_fromTableToString = function (tbl)
            local t = ""; 
            for _, v in pairs(tbl) do 
                t = t .. tostring(v); end
            return t 
        end; 

        get_truesInTable = function (tbl, alternative_table)
            local trues = {}; 
            for _, v in pairs(tbl) do
                if ( v == true ) then 
                    if ( alternative_table ~= nil ) then 
                        trues[#trues+1] = alternative_table[_]; 
                    else
                        trues[#trues+1] = v; end; end; end 
            return trues; 
        end; 

        round = function (num, int)
            return tonumber(string.format("%"..tostring(int)..".f", num)); 
        end;  

        time_toTicks = function (self, seconds) 
            return self.round(seconds/globals.tickinterval, 0); 
        end; 

    }

}