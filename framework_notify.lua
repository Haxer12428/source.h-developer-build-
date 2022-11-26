FW.notify = {

    _ = {

        storage = {

            screen = { 
                
                instances = {}; 

            }; 

        }; 


        screen = {

            render_styles = function (instance) 
                
                local styles = {

                    ["basic"] = function () 
                        local rounding = 2; 

                        local position = instance.__defaultPosition - vector(0, instance.__add); 
                        local box_position_a = position - vector(instance.final_size.x/2, instance.final_size.y + instance.additional_size_y/2); 
                        local box_position_b = box_position_a + instance.final_size + vector(0, instance.additional_size_y/2); 

                        
                        render.blur(
                            box_position_a,
                            box_position_b,
                            1.0,
                            1.0,
                            rounding
                        )

                        render.rect_outline(
                            box_position_a, 
                            box_position_b, 
                            instance.colored, 
                            1,
                            rounding
                        ) 
                        
                        local name_position_y = box_position_a.y + (box_position_a.y - box_position_b.y); 
                        local name_position_full = vector(box_position_a.x, name_position_y); 

                        render.text(
                            instance.font,
                            name_position_full,
                            instance.colored,
                            nil,
                            instance.name
                        )

                    end; 

                }; 
                styles[instance.style](); 
            end;    

            render_instances = function (self, instances) 
                local __add = 10; 
                local __defaultPosition = vector(render.screen_size().x/2, render.screen_size().y - 90); 
                local __gaps = 10; 
                local additional_size_y = 20; 

                for _, instance in pairs(instances) do 

                    local message = instance.message.." "; 
                    local name = " "..instance.name.." "; 

                    local alpha = instance.alpha; 

                    local colored = instance.color:alpha_modulate(alpha); 
                    local uncolored = color(255, 255, 255, 255);

                    local id = instance.id; 
                    local style = instance.style; 
                    local font = 3; 

                    local message_size = measure_text(font, nil, message); 
                    local name_size = measure_text(font, nil, message); 
                    local final_size = message_size + vector(name_size.x, 0); 
                

                    local arguments = {
                        message = message;
                        name = name; 
                        alpha = alpha; 
                        colored = colored; 
                        uncolored = uncolored; 
                        id = id; 
                        style = style; 
                        font = font; 
                        message_size = message_size;
                        name_size = name_size; 
                        final_size = final_size; 
                        additional_size_y = additional_size_y; 
                        __add = __add; 
                        __defaultPosition = __defaultPosition; 
                    }; 

                    self.render_styles(arguments)
                    __add = __add + final_size.y + __gaps + additional_size_y; 
                end; 

            end; 

        }; 

        
        init = function (self) 

            events.render:set(
                function () 
                    self.screen:render_instances(self.storage.screen.instances); 
                end)

        end;    
    }; 

    ["=>"] = {

        push_screen = function (message, name, render_style, timer, color)
            FW.notify._.storage.screen.instances[#FW.notify._.storage.screen.instances+1] = {
                id = #FW.notify._.storage.screen.instances + 1; 
                style = render_style; 
                message = message; 
                name = name; 
                timer = globals.realtime + timer; 
                color = color; 
                alpha = color.a; 
            }; 
        end; 

    }

}; 


FW.notify._:init(); 