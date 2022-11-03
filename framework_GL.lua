FW.GL = { 

    _ = {

        render = {}; 

        clear_render = function (self) 
            self.render = {}; 
        end; 

        update_render = function (self) 
            local table = self.render; 
            for _, que in pairs(table) do 
                for struct_name, struct in pairs(que) do 
                    
                    render.push_rotation(struct.__rotation); 
                    render.push_clip_rect(struct.__clip[1], struct.__clip[2], false);  

                    draw[struct.__renderStructure](unpack(struct.__arguments, 1, #struct.__arguments));

                    render.pop_rotation();  
                    render.pop_clip_rect(); 
                    
                end; end 

            self:clear_render(); 
        end; 

        init = function (self) 

            events.render:set(
                function () 
                    self:update_render(); 
                end); 

        end; 

    }; 

    ["=>"] = {

        render = function (render_struct, priority, clip1, clip2, rotation, ...) 
            clip1 = clip1 == nil and vector(0, 0) or clip1; 
            clip2 = clip2 == nil and render.screen_size() or clip2; 
            rotation = rotation == nil and 0 or rotation;

            local arguments = {
                __renderStructure = render_struct;
                __clip = {clip1, clip2}; 
                __rotation = rotation;
                __arguments = {...}; 
            }; 

            if (FW.GL._.render[priority] == nil) then FW.GL._.render[priority] = {}; end 
            FW.GL._.render[priority][#FW.GL._.render[priority]+1] = arguments; 
        end; 

    }; 

}

FW.GL._:init(); 
