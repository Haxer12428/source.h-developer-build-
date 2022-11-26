FW.game = {

    _ = {

        storage = {

            round_started = true; 

        }; 

        round_started = {

            prestart = function () 
                FW.game._.storage.round_started = false; 
            end; 

            cs_intermission = function ()
                FW.game._.storage.round_started = false; 
            end; 

            start_halftime = function () 
                local game_rules = entity.get_game_rules(); 
                local current_round = game_rules.m_totalRoundsPlayed; 
                local maximum_round = cvar.mp_maxrounds:int(); 

                if (current_round ~= maximum_round/2) then 
                    return end 

                FW.game._.storage.round_started = false; 
            end; 
            
            round_freeze_end = function () 
                FW.game._.storage.round_started = true; 
            end; 

        }; 

        init = function (self) 

            events.round_prestart:set(
                function ()
                    self.round_started.prestart(); 
                end)
            
            events.round_freeze_end:set(
                function ()
                    self.round_started.round_freeze_end(); 
                end)

            events.cs_intermission:set(
                function ()
                    self.round_started.cs_intermission(); 
                end)

            events.round_end:set(
                function ()
                    self.round_started.start_halftime(); 
                end)
            
        end; 

    }; 

    ["=>"] = {

        get_info = function () 
            return FW.game._.storage; 
        end; 

        get_varByName = function (name) 
            return FW.game._.storage[name];
        end; 

    }; 

}; 

FW.game._:init(); 