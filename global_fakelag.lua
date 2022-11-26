global.fakelag = {

    _ = {

        set = {

            prevent_FL = function (table) 
                local FL = FW.GameVars["=>"].get_var("FL_ENABLE");

                local conditions = {

                    ["Exploit Not Charged"] = function () 
                        local is_exploiting = FW.GameVars["=>"]:is_exploiting(); 

                        if (not is_exploiting) then 
                            return false; end 

                        local charge = rage.exploit:get() ~= 1; 

                        return charge; 
                    end; 

                }; 

                for _, con in pairs(table) do 
                    if (conditions[con] ~= nil) then 
                        if (conditions[con]() == true) then 
                            FL:set(false); 
                            return
                        end 
                end; end

                FL:set(true); 
            end; 

        }; 

        init = function (self) 

            events.createmove:set(
                function ()
                    self.set.prevent_FL(global.menu["=>"].get_elements().prevent_fakelang_options:get());
                end)

        end;    

    }; 
    
    ["=>"] = {

    }

}; 

global.fakelag._:init();