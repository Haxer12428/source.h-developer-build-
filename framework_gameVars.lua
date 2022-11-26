FW.GameVars = {

    _ = {

        var_list = {

            enable_mouse = "cl_mouseenable"; 
            DT = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"); 
            HS = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"); 

            FL_ENABLE = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"); 

            BAIM = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim");
            SAFEPOINT = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"); 

            PITCH = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"); 
            YAWMODE = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"); 
            YAWOFFSET = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"); 
            YAWBASE = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"); 
            MODIFIER = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"); 
            MODIFIEROFFSET = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"); 
            BODYYAW = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw");
            FREESTAND = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"); 
        }

    }; 

    ["=>"] = {

        get_list = function () 
            return FW.GameVars._.var_list; 
        end; 

        get_var = function (name, value) 
            if (value == true) then 
                return FW.GameVars._.var_list[name]:get(); end 
            return FW.GameVars._.var_list[name];  
        end;  

        get_enabledExploit = function (self)
            local DT, HS = self.get_var("DT", true), self.get_var("HS", true); 
            if (DT) then 
                return "DT"; end 
            if (HS) then 
                return "HS"; end 
            return nil; 
        end; 

        is_exploiting = function (self) 
            local DT, HS = self.get_var("DT", true), self.get_var("HS", true);  
            if (DT or HS) then return true; end 
            return false; 
        end;  

        is_baiming = function (self)
            local baim = self.get_var("BAIM", true); 
            if (baim ~= "Default") then 
                return true; end 
            return false; 
        end; 

        is_safepointing = function (self)
            local sp = self.get_var("SAFEPOINT", true); 
            if (sp ~= "Default") then return true; end 
            return false;
        end; 

        find_bindByName = function (name)
            local binds = ui.get_binds(); 

            for _, bind in pairs(binds) do 
                if (bind.name == name) then
                    return bind; 
                end; end 
            return nil; 
        end; 

    }

}