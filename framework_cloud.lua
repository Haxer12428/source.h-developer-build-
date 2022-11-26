FW.cloud = { 
    --//mockapi.io

    _ = {}; 

    ["=>"] = {

        find_userByName = function (url, name) 
            local data = FW.panorama["=>"].json.parse(network_get(url)); 
            if (data == "null") then 
                return "Invaild url"; end 

            for _, user in pairs(data) do 
                if (user.name == name) then 
                    return user; 
                end; end 
            
            return nil; 
        end; 

        create_user = function (self, url, name, data)
            if (data == nil) then data = {}; end 
            if (self.find_userByName(url, name) ~= nil) then 
                return end  
            
            local creation_date = common.get_date("%m/%d/%Y"); 
            data.name = name; 
            data.created = creation_date; 

            FW.panorama['=>'].http.request(url, {
                type = "POST";
                data = data; 
            })
        end;  

        update_user = function (self, url, name, data) 
            local usr = self.find_userByName(url, name)
            if (usr == nil) then 
                print("Not a valid user!"); return end 

            local id = usr.id; 

            FW.panorama['=>'].https:request("put",
                string.format('%s%s', url, id),
                {headers = {['content-type'] = 'application/json'}, body = json.stringify(data)},
                function (data) end
            )
        end; 

        get_allUsers = function (url)
            return FW.panorama["=>"].json.parse(network_get(url)); 
        end; 

    }

}; 