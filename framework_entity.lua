FW.entity = {

    _ = {

        storage = {

            enemies_activeIncludeDormant = {}; 
            enemies_active = {}; 

        }; 

        get_activeEnemies = function (self) 
            local ents = entity.get_players(true);
            local includeDormant = {}; 
            local nonDormant = {}; 

            for _, enemy in pairs(ents) do 

                if (enemy:is_alive()) then 
                    includeDormant[#includeDormant+1] = enemy; 

                    if (not enemy:is_dormant()) then 
                        nonDormant[#nonDormant+1] = enemy; 
                    end;
                end; 
            end; 

            self.storage.enemies_activeIncludeDormant = includeDormant; 
            self.storage.enemies_active = nonDormant; 
        end;     

        init = function (self)

            events.createmove:set( 
                function () 
                    self:get_activeEnemies(); 
                end)

        end; 

    }; 

    ["=>"] = {

        get_activeEnemies = function (dormancy) 
            return dormancy and FW.entity._.storage.enemies_activeIncludeDormant or FW.entity._.storage.enemies_active; 
        end 
    }

}; 

FW.entity._:init(); 