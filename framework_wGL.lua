FW.wGL = {

    _ = {

        structure = {

            render = {

                default_box = function (__data) 
                    local position = __data.__main.position; 
                    local size = __data.__main.size; 
                    local clr = __data.__main.color; 
                    local rounding = __data.__main.rounding; 

                    FW.GL["=>"].render(
                        "rect",
                        2,
                        nil,
                        nil,
                        nil,
                        position,
                        position + size,
                        clr,
                        rounding  

                    )

                end; 

            }; 

            handlers = {

                move_update = function (__data)
                    if (not key_hold(1)) then 
                        __data.__main.move.active = false; return end 

                    local position = __data.__main.move.position; 
                    local mouse_position = ui.get_mouse_position(); 
                        
                    __data.__main.position = mouse_position + position; 
                end;    

                move = function (self, __data) 
                    if (__data.__main.move.active) then 
                        self.move_update(__data); return end 

                    if (not __data.__main.inputs.allow_move) then 
                        return end 

                    if (not FW.userInput["=>"].key_press(1)) then 
                        return end 

                    local position_start = __data.__main.position; 
                    local position_end = position_start + __data.__main.size; 

                    if (not FW.mouse["=>"].is_inPosition(position_start, position_end)) then 
                        return end 

                    local mouse_from = FW.mouse["=>"].from(position_start); 

                    __data.__main.move.active = true; 
                    __data.__main.move.position = mouse_from; 
                end; 

            };  

            object_system = {

                main = function (self, __data)    
                    local object_list = __data.__objects; 

                    for _, object in pairs(object_list) do 
                        for fn, f in pairs(object.__run) do 
                            
                            local call = f(object.__storage); 
                            if (call ~= 0) then 
                                error("[wGL] Object function '" .. fn .. "' error.", 1); end
                        end; end 
                end; 

            }; 

            init = function (self, __data)

                events.render:set(
                    function () 
                        self.handlers:move(__data); 
                        self.render.default_box(__data); 
                        self.object_system:main(__data); 
                    end)  

            end; 

        }; 

        object_structure = {
            __run = {
                main = function ()
                    return 0; 
                end; }; 
            __storage = {}; 
        }; 

    }; 

    ["=>"] = {

        new = function () 
            local tbl = { 
                __struct = FW.wGL._.structure; 
                __data = { 
                    __main = {
                        position = vector(300, 300); 
                        size = vector(0, 0);
                        color = color(0, 0, 0, 0); 
                        rounding = 0; 

                        inputs = {
                            allow_move = false; 
                        }; 

                        move = {
                            position = vector(0, 0); 
                            active = false; 
                        }
                    }; 

                    __objects = {}; 
                }; }; 

            return setmetatable(tbl, nil); 
        end;  

        new_object = function (structure) 
            local object_struct = setmetatable(FW.wGL._.object_structure, nil); 
            structure.__data.__objects[#structure.__data.__objects+1] = object_struct; 

            return structure.__data.__objects[#structure.__data.__objects]; 
        end; 

        init = function (structure)  
            structure.__struct:init(structure.__data); 
        end;

        set_size = function (structure, size)
            structure.__data.__main.size = size; 
        end; 

        set_main_color = function (structure, color) 
            structure.__data.__main.color = color; 
        end;    

        set_position = function (structure, position)
            structure.__data.__main.position = position; 
        end; 

        allow_move = function (structure, state)
            structure.__data.__main.inputs.allow_move = state; 
        end;  

    }
}   