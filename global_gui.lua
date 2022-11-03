global.gui = {

    _ = {

        init = function (self) 
            self.storage = {
                
                __main = {

                    color = color(0, 0, 0, 255); 
                    default_position = vector(200, 100); 
                    size = vector(500, 720); 

                }

            }; 

            local gui_structure = FW.wGL["=>"].new();  

            FW.wGL['=>'].set_main_color(gui_structure, self.storage.__main.color); 
            FW.wGL["=>"].set_position(gui_structure, self.storage.__main.default_position); 
            FW.wGL['=>'].set_size(gui_structure, self.storage.__main.size); 

            FW.wGL["=>"].init(gui_structure); 

            self.gui_struct = gui_structure; 
        end; 

    }; 

    ["=>"] = {}; 

}

global.gui._:init(); 