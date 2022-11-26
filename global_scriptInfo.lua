global.script_info = {

    _ = {

        storage = {

            name = "source-h"; 
            build = "beta"; 
            users_url = "https://636fa462f2ed5cb047e1d815.mockapi.io/api/build/users/"; 

        }

    }; 

    ["=>"] = {

        get = function (variable)
            if (variable ~= nil) then 
                return global.script_info._.storage[variable]; end  
            return global.script_info._.storage;
        end; 

    }

}