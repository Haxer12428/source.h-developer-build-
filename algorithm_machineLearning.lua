local algorithm = {}; 

algorithm.machineLearning = {

    _ = {

        work = {
            storage = {
                gen = 1; 
                last_direction = ""; 
                last_directionSwap = 0; 
                __ = {}; 
            }; 

            swap = function (self, list, args)
                local attacker = entity.get(args.attacker, true); 
                local storage = self.storage; 

                if (attacker ~= entity.get_local_player()) then 
                    return end 
                
                local functions = {
                    ["modifier"] = function (data)
                        local tries = storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current].tries

                        if (tries < data.tries) then 
                            storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current].tries = tries + 1; 
                            print("Added a try"); 
                            return end 

                        print("Changed an offset")
                        storage.__[storage.gen].modifiers.current = storage.__[storage.gen].modifiers.current + 1; 
                    end
                }

                for _, listed in pairs(list) do 
                    functions[listed.name](listed); end 

                print("Succesfully changed this bitches"); 
            end; 

            count_misses = function (self, list, args)
                if (args.state == nil) then 
                    return end 

                local storage = self.storage; 

                local functions = {
                    ['modifier'] = function (data) 
                        storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current].count = storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current].count + 1; 
                        storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current].missed_sides[#storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current].missed_sides+1] = FW.angles['=>'].get_inverter(); 
                    end; 
                }

                for _, listed in pairs(list) do 
                    functions[listed.name](listed); end;
                print('registered a fuckin miss');
            end; 

            move_state = function (self, name, cmd)
                local ref = self.storage; 

                local move_states = {
                    ["run"] = function () 
                        if (ref.last_directionSwap + 2 > globals.realtime) then 
                            return end 

                        ref.last_directionSwap = globals.realtime; 

                        if (ref.last_direction == "=>") then 
                            ref.last_direction = "<="; return end 
                        ref.last_direction = "=>"; 
                    end;
                }; 

                move_states[name](); 

                --//handle sides 
                if (ref.last_direction == "=>") then 
                    cmd.sidemove = 200; return end 

                if (ref.last_direction == "<=") then 
                    cmd.sidemove = -200; return end 

            end; 

            printout = function (self) 
                local best_possibleOutput = nil; 
                local best_outputs = {}; 

                for _, gen in pairs(self.storage.__) do 
                    print("----------------- GEN ", _, "-------------------"); 
                    local all_in = {}; 
                    
                    for __, mod in pairs(gen.modifiers.all) do
                        local get_mostMissedSide = function (sides) 
                            local t1, f1 = 0, 0; 
                            for _, side in pairs(sides) do
                                if (side == true) then 
                                    t1 = t1 + 1; else f1 = f1 + 1; 
                                end; end 
                            return t1 < f1 and false or true 
                        end; 

                        if (mod.count ~= nil) then 
                            all_in[__] = mod.count; end 
                        
                        print(__, " <= ", tostring(get_mostMissedSide(mod.missed_sides)) ," ==> ", mod.count); 
                    end 
                
                    local get_bestModifier = function () 
                        local last_num = 0; 
                        local last_index = 0; 
                        for _, num in pairs(all_in) do 
                            if (num > last_num) then 
                                last_num = num; last_index = _;
                            end
                        end;
                        return {last_index, last_num};
                    end; 
        
                    print("Best modifier found is: ", get_bestModifier()[1], " with miss count: ", get_bestModifier()[2]);
                    best_outputs[#best_outputs+1] = {get_bestModifier()[1], get_bestModifier()[2]}; 
                end;

                print("[------------------------------------------]")

                local last_bestOutput = {0, 0};

                for _, output in pairs(best_outputs) do 
                    if (output[2] > last_bestOutput[2]) then
                        last_bestOutput = {output[1], output[2]}; 
                    end
                end 


                print("[ Best output: ", last_bestOutput[1], "; count: ", last_bestOutput[2], "; gens: ", self.storage.gen, ".");
                print("[------------------------------------------]")
            end; 

            set = function (self)
                local storage = self.storage; 
                local modifier = storage.__[storage.gen].modifiers.current; 

                FW.angles['=>'].override_modifier(modifier);
            end; 

            main = function (self, list) 
                local storage = self.storage; 

                local types = {
                    ["modifier"] = function (data) 

                        if (storage.__[storage.gen] == nil) then 
                            storage.__[storage.gen] = {}; end 

                        if (storage.__[storage.gen].modifiers == nil) then 
                            storage.__[storage.gen].modifiers = {}; end 

                        if (storage.__[storage.gen].modifiers.current == nil) then 
                            storage.__[storage.gen].modifiers.current = data.range[1]; end 

                        if (storage.__[storage.gen].modifiers.all == nil) then 
                            storage.__[storage.gen].modifiers.all = {}; end 
                        
                        if (storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current] == nil) then 
                            storage.__[storage.gen].modifiers.all[storage.__[storage.gen].modifiers.current] = { count = 0; tries = 0; missed_sides = {}; }; end 

                        if (storage.__[storage.gen].modifiers.current > data.range[2]) then 
                            storage.gen = storage.gen + 1; end 

                    end;
                }

                for _, listed in pairs(list) do 
                    types[listed.name](listed); end 
            end; 

        }; 

        init = function (self) 
            --//prioritizing first one as a main gen factor 
            local swap_list = {
                {
                    name = "modifier",
                    range = {40, 90},
                    tries = 4; 
                }
            }

            --// creating tables etc. 
            events.createmove:set(
                function ()
                    self.work:main(swap_list);
                end)

            --// awake of swap sys 
            events.player_death:set(
                function (args)
                    self.work:swap(swap_list, args);
                end
            )

            --// set values 
            events.createmove:set(
                function ()
                    self.work:set(); 
                end
            )

            --// printout 
            events.console_input:set(
                function ()
                    self.work:printout(); 
                end
            )

            --// register misses 
            events.aim_ack:set(
                function (args)
                    self.work:count_misses(swap_list, args); 
                end
            )

            --// move 
            events.createmove:set(
                function (cmd)
                    self.work:move_state("run", cmd); 
                end
            )
            
        end; 

    }

}

algorithm.machineLearning._:init(); 