
FW.log = {

    message = { 

        __init__ = function (self)
            self.messages = {}; 
            self.id = 0; 

            self.reset_time = 6; 
            
            events.render:set(function () self:__render__(); self:__reset__(); end); 
        end; 

        new = function (self, base_color, color, text)
            self.id = self.id + 1; 
            self.messages[#self.messages+1] = {
                default_color = base_color; 
                creation_time = globals.realtime; 
                alpha = 255; 
                color = color; 
                text = text; 
                id = self.id; 
            }; 
        end; 

        __reset__ = function (self)

            local reset_after = self.reset_time; 
            local maxiumum_amount = 8; 

            for _, message in pairs(self.messages) do 

                local message_time_left = message.creation_time + reset_after - globals.realtime; 
                
                if ( _ > maxiumum_amount ) then 
                    table.remove(self.messages, 1); end 

                if ( message_time_left < 0 ) then 
                    table.remove(self.messages, _); end 

                if ( message_time_left < 0.25 ) then  

                    message.alpha = FW.animate['=>']:basic(_.."msg_Log"..message.creation_time, 255*3, 255, 0); 

                end

            end
            
        end; 

        __render__ = function (self)
            
            local script_name = "source.h";
            local screen_size = render.screen_size(); 
            local starting_position_center = vector(screen_size.x/2, screen_size.y - 90); 
            local font = 1;

            local starting_position_add = 0; 

            for _, message in pairs(self.messages) do 

                local color2 = function (color)
                    color.a = math.min(message.alpha, color.a); 
                    return color 
                end

                local text = message.text
                local text_full = FW.math["=>"].values_fromTableToString(text):gsub("&&", ""):gsub("\n", ""); 
                local text_full_size = vector( render.measure_text(font, nil, text_full).x, render.measure_text(font, nil, text_full).y ); 

                local main_color = color2(message.color); 
                local default_color = color2(message.default_color); 

                local starting_position = starting_position_center - vector(text_full_size.x/2, FW.animate['=>']:basic(message.id.."_", 250, starting_position_add - 14, starting_position_add)); 

                local box_additional_size = vector(14, 10); 
                local box_right_size_add = vector(14, 0); 
                local box_starting_position = starting_position + vector(0, 1) - box_additional_size/2;
                local box_end_position = starting_position + vector(text_full_size.x, text_full_size.y) + box_additional_size/2; 
                local box_rounding = 6; 

                local circle_size = text_full_size.y - 6; 
                local circle_additional_position = vector(7, box_additional_size.y/2 + text_full_size.y/2);  

                local box_outline_size = 1; 
                local glow_size = 10; 

                render.rect(
                    box_starting_position - glow_size/2, 
                    box_end_position + glow_size/2 + box_right_size_add, 
                    color2(main_color:alpha_modulate(8)),
                    box_rounding
                )

                render.gradient(
                    box_starting_position - box_outline_size,
                    box_end_position + box_outline_size + box_right_size_add,
                    color2(main_color),
                    color2(main_color),
                    color2(main_color:alpha_modulate(50)),
                    color2(main_color:alpha_modulate(50)),
                    box_rounding 
                )
                
                render.rect(
                    box_starting_position,
                    box_end_position + box_right_size_add,
                    color(0,0,0,message.alpha*1.80), 
                    box_rounding 
                ) 

                render.circle_outline(
                    vector(box_end_position.x - 5, box_starting_position.y) + circle_additional_position,
                    color2(main_color),
                    circle_size,
                    270,
                    (message.creation_time + self.reset_time - globals.realtime)/self.reset_time,
                    2
                )

                local reformat_text = function (table, c1, c2)
                    local str = ""; 
                    for _, partion in pairs(table) do 
                        local clr = c1; 
                        if (string.match(partion, "&&")) then
                            partion = partion:gsub("&&", ""); clr = c2; end 
                        str = str .. "\a" .. clr:to_hex() .. partion; 
                    end;    
                    return str
                end; 
                
                render.text(
                    font, 
                    starting_position,
                    color2(default_color),
                    nil,
                    reformat_text(text, color2(default_color), color2(main_color))
                )

                starting_position_add = starting_position_add + text_full_size.y + box_additional_size.y + 12; 

            end

        end


    }; 

    ["=>"] = {

        new = function (base_color, color, text)
            FW.log.message:new(base_color, color, text);
        end 

    }
}

FW.log.message:__init__(); 

FW.log.message:new(color(255, 255, 255, 255), color(0, 180, 255, 255), {"haha&&", " you'r", " black&&!"});