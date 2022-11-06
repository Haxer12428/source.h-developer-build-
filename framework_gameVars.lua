FW.GameVars = {

    _ = {

        var_list = {

            enable_mouse = "cl_mouseenable"; 

        }

    }; 

    ["=>"] = {

        get_list = function () 
            return FW.GameVars._.var_list; 
        end; 

        get_var = function (name) 
            return FW.GameVars._.var_list[name];  
        end; 

    }

}