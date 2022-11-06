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
                    
                    if (struct.__rotation ~= nil) then render.push_rotation(struct.__rotation); end; 
                    if (struct.__clip[1] ~= nil) then render.push_clip_rect(struct.__clip[1], struct.__clip[2], false); end; 

                    draw[struct.__renderStructure](unpack(struct.__arguments, 1, #struct.__arguments));

                    if (struct.__rotation ~= nil) then render.pop_rotation(); end;   
                    if (struct.__clip[1] ~= nil) then render.pop_clip_rect(); end; 
                    
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
            local arguments = {
                __renderStructure = render_struct;
                __clip = {clip1, clip2}; 
                __rotation = rotation;
                __arguments = {...}; 
            }; 

            if (FW.GL._.render[priority] == nil) then FW.GL._.render[priority] = {}; end 
            FW.GL._.render[priority][#FW.GL._.render[priority]+1] = arguments; 
        end; 

        get_clipRect = function (...) 
            local args = {...}; 
            local x1, y1 = {}, {}; 
            local x2, y2 = {}, {};

            for _, clips in pairs(args) do 
                x1[#x1+1] = clips[1].x; x2[#x2+1] = clips[2].x; 
                y1[#y1+1] = clips[1].y; y2[#y2+1] = clips[2].y; 
            end; 
            
            local proper_clip = {
                vector( math.max(unpack(x1)), math.max(unpack(y1)) ); 
                vector( math.min(unpack(x2)), math.min(unpack(y2)) ); }
            
            return proper_clip; 
        end; 

    }; 

}

FW.GL._:init(); 
