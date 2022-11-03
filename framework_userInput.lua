FW.userInput = {

    _ = {

        keys = {}; 

        keys_update = function (self) 
            local registered_keys = 180; 

            for index = 1, registered_keys do
                local active = common.is_button_down(index)
                if (not active) then
                    self.keys[index] = {
                        active = false;
                        updated = globals.realtime + 1; 
                    }; 
                    goto after
                end
        
                if (self.keys[index] == nil) then
                    goto after; end

                self.keys[index].active = false;

                if (self.keys[index].updated > globals.realtime) then
                    if (active) then  
                        self.keys[index].updated = 0;
                        self.keys[index].active = true;
                    end; end 
        
                ::after::
            end
        end;    

        init = function (self) 

            events.render:set(
                function () 
                    self:keys_update(); 
                end);   

        end; 

    }; 

    ["=>"] = {

        key_press = function (num) 
            if (FW.userInput._.keys[num] == nil) then 
                return false; end 
            return FW.userInput._.keys[num].active; 
        end; 

    }

}

FW.userInput._:init(); 