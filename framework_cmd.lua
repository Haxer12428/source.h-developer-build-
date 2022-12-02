FW.cmd = {

    _ = { 

        gui = { 

            _G = {

                ["$"] = {

                    global_size = vector(850, 550); 
                    global_color = color(0, 0, 0, 255); 

                    topbar_size = vector(0, 23); 

                    outline_size = 1; 
                    outline_color = color(255, 255, 255, 35); 

                    global_sliderSize = vector(15, 0); 

                    typespace_color =  color(128, 128, 128, 29);

                    typetext_additionalPosition = vector(2, -2);

                    typetext_color = color(255, 255, 255, 255); 

                }; 

                ['<='] = {

                    print_blocks = {}; 

                    text_typedIn = "Hello i cant talk but i can code[>-<]"; 

                }; 
            
            }; 

            wGL_config = {

                config = function (_G) 

                    local struct = FW.wGL['=>'].new(); 
                    FW.wGL['=>'].allow_move(struct, true); 
                    FW.wGL['=>'].block_input(struct, true); 
                    FW.wGL['=>'].set_main_color(struct, _G.global_color); 
                    FW.wGL['=>'].set_size(struct, _G.global_size); 
                    FW.wGL['=>'].set_movePositions(struct, vector(0, 0), vector(_G.global_size.x, _G.topbar_size.y));

                    FW.wGL['=>'].init(struct);

                    return struct; 
                end; 

                init = function (self) 
                    return {
                        setup = self.config; 
                    }
                end;

            };

            render = {

                outline = {
                    render = function (_G, struct)
                        local position = FW.wGL['=>'].get_position(struct); 
                        local size = FW.wGL['=>'].get_size(struct); 
                        local smath = vector(_G.outline_size, _G.outline_size); 

                        FW.GL['=>'].render("rect_outline", 2,
                            nil,
                            nil,
                            nil,
                            position - smath,
                            position + size + smath,
                            _G.outline_color,
                            _G.outline_size
                        )
                    end; 

                    init = function (self)
                        return {
                            hook = self.render
                        }
                    end
                }; 

                typespace = {
                    render_box = function (_G, struct) 
                        local position = FW.wGL['=>'].get_position(struct); 
                        local size = FW.wGL['=>'].get_size(struct); 

                        local start = position + _G.topbar_size; 
                        local final = start + size - _G.global_sliderSize - _G.topbar_size; 

                        FW.GL['=>'].render("rect", 2,
                            nil, nil, nil, start, final, _G.typespace_color
                        );
                    end; 

                    render_text = function (_G, _G2, struct) 
                        local position = FW.wGL['=>'].get_position(struct);
                        local size = FW.wGL['=>'].get_size(struct); 

                        local final = position + size + _G.typetext_additionalPosition; 
                        local font = 1; 

                        FW.GL['=>'].render("text", 2,
                            nil, nil, nil, font, final, color(255, 255, 255, 255), nil, "text"
                        )
                    end; 

                    handler = function (self, _G, _G2, struct) 

                        self.render_box(_G, struct); 
                        self.render_text(_G, _G2, struct); 

                    end; 

                    init = function (self)
                        return {
                            hook = function (_G, _G2, struct) self:handler(_G, _G2, struct); end 
                        }
                    end; 
                }; 

                handler = function (self, _G, _G2, struct) 
                    
                    local outline = self.outline:init(); 
                    local typespace = self.typespace:init(); 

                    outline.hook(_G, struct); 
                    typespace.hook(_G, _G2, struct);

                end; 

                init = function (self) 
                    return {
                        hook = function (_G, _G2, struct) self:handler(_G, _G2, struct); end
                    }
                end; 
            }; 

            main = function (self) 
                local _G = self._G["$"]; 
                local _G2 = self._G['<=']; 

                local wGL_config = self.wGL_config:init(); 
                local wGL_render = self.render:init(); 

                local struct = wGL_config.setup(_G); 

                local hook = FW.wGL['=>'].new_object(struct); 

                hook:override_mainFunctions( 
                    function ()
                        
                        wGL_render.hook(_G, _G2, struct); 

                        return 0; 
                    end)

            end; 

        }; 


        init = function (self)
            self.gui:main(); 


        end; 

    }; 

}

FW.cmd._:init(); 