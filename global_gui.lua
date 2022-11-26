global.gui = {

    _ = {

        settings = {

            vectors = {

                main_panel = vector(90, 0);
                upper_panel = vector(0, 30); 

                elements_render_start = vector(10, 10); 
                elements_render_end = vector(10, 0); 

            }; 

            colors = {

                main_panelLine = color(255, 255, 255, 100); 
                upper_panelLine = color(255, 255, 255, 100); 

            }

        }; 

        structure = {

            __essentials = {

                base_layout = function (self, struct, settings)
                    local gui_position = FW.wGL["=>"].get_position(struct); 
                    local gui_size = FW.wGL["=>"].get_size(struct);

                    local upper_panelSize = vector (gui_size.x, settings.vectors.upper_panel.y);  
                    local upper_panelPositionA = gui_position + vector (0, upper_panelSize.y); 
                    local upper_panelPositionB = upper_panelPositionA + vector(upper_panelSize.x, 0); 
                    local upper_panelColor = settings.colors.upper_panelLine; 

                    local main_panelSize = vector (settings.vectors.main_panel.x, gui_size.y - upper_panelSize.y); 
                    local main_panelPositionA = gui_position + vector(main_panelSize.x, upper_panelSize.y + 1); 
                    local main_panelPositionB = main_panelPositionA + vector(0, main_panelSize.y - 1); 
                    local main_panelColor = settings.colors.main_panelLine; 


                    FW.GL['=>'].render(
                        "line",
                        4,
                        nil,
                        nil,
                        nil,
                        main_panelPositionA, 
                        main_panelPositionB,
                        main_panelColor 
                    )

                    FW.GL["=>"].render(
                        "line",
                        4,
                        nil,
                        nil,
                        nil,
                        upper_panelPositionA,
                        upper_panelPositionB,
                        upper_panelColor
                    )

                    return 0; 
                end; 

                get_elements_size = function (table, name) 
                    local sizes = {
                        ["checkbox"] = 20; 
                    }; local length = 0; 

                    for _, el in pairs(table) do 
                        if (el.__global.name == name) then 
                            return length; end 

                        length = length + sizes[el.__global.type];
                    end; 

                    return length; 
                end; 

            }; 

            __elements = {

                __data = {

                    list = {}; 

                }; 

                struct = {

                    tab = function (element, gui_struct) 
                        local g = element.__global; 
                        if (not g.visible) then 
                            return end 

                        local name = g.name; 
                        g.__run:init(element); 
                    end; 

                };

                init = function (self, gui_struct, settings) 
                    local element_struct = FW.wGL["=>"].new_object(gui_struct); 

                    element_struct.__run.main = function () 

                        for _, element in pairs(self.__data.list) do 

                            self.struct["tab"](element, gui_struct); 

                        end; return 0; end; 

                end; 

            }; 

            init = function (self, gui_struct, settings) 

                local base_layout = FW.wGL["=>"].new_object(gui_struct); 
                base_layout.__run.main = function () return self.__essentials:base_layout(gui_struct, settings) end; 

                self.__elements:init(gui_struct, settings); 

            end; 

        }; 

        init = function (self) 
            self.storage = {
                
                __main = {

                    color = color(0, 0, 0, 255); 
                    default_position = vector(200, 100); 
                    size = vector(720, 500); 

                }

            }; 

            local gui_structure = FW.wGL["=>"].new();  

            FW.wGL['=>'].set_main_color(gui_structure, self.storage.__main.color); 
            FW.wGL["=>"].set_position(gui_structure, self.storage.__main.default_position); 
            FW.wGL['=>'].set_size(gui_structure, self.storage.__main.size); 
            FW.wGL["=>"].allow_visibility_change(gui_structure, true); 
            FW.wGL["=>"].set_visibility_change_key(gui_structure, 35); 
            FW.wGL["=>"].allow_move(gui_structure, true); 

            FW.wGL["=>"].init(gui_structure); 

            self.gui_struct = gui_structure; 
            self.structure:init(self.gui_struct, self.settings); 
        end; 

    }; 

    ["=>"] = {

        new = {

            tab = function (name) 
                local struct = {
                    __global = {
                        name = name; 
                        visible = true; 

                        __run = {

                            get_position = function (struct) 

                                local gui_position = FW.wGL["=>"].get_position(struct); 
                                local gui_size = FW.wGL["=>"].get_size(struct); 

                                local start_renderPosition = global.gui._.settings.vectors.elements_render_start; 

                                local available_size = global.gui._.settings.vectors.

                            end; 

                            init = function (self, element, gui_struct)
                                
                                self.get_position(gui_struct); 

                            end; 

                        }
                    }; 
                    __data = {
                        elements = {}; 
                    }
                }; 

                global.gui._.structure.__elements.__data.list[#global.gui._.structure.__elements.__data.list+1] = struct; 
            end; 

        };

    }; 

}

global.gui["=>"].new.tab("nigger123");

global.gui._:init(); 