global.user = {

    _ = {

        storage = {

            user = {
                id = "restart script";
                created = "restart script";
            }; 

        }; 

        handle_userInfo = function (self) 
            local userURL = global.script_info["=>"].get("users_url"); 
            local username = get_cheat_username(); 

            local exists = FW.cloud["=>"].find_userByName(userURL, username); 

            local config = global.menu['=>'].save_config();  

            if (exists ~= nil) then 
                self.storage.user = exists; return end 

            FW.cloud["=>"]:create_user(userURL, username, {config = config}); 
            self.storage.user = FW.cloud["=>"].find_userByName(userURL, username); 
        end; 

        init = function (self) 
            self:handle_userInfo(); 
        end;    

    };  

    ["=>"] = {

        get_data = function (variable)
            if (variable ~= nil) then
                return global.user._.storage.user[variable]; end 
            return global.user._.storage.user;
        end; 

        update_myConfig = function () 
            local userURL = global.script_info["=>"].get("users_url"); 
            local username = get_cheat_username(); 
            local config = global.menu['=>'].save_config();  

            FW.cloud['=>']:update_user(userURL, username, {config = config});
        end; 

        get_userNamesWithConfigAvailable = function () 
            local userURL = global.script_info["=>"].get("users_url"); 
            local users = FW.cloud['=>'].get_allUsers(userURL); 
        
            local names = {};
            for _, user in pairs(users) do 
                if (user.config ~= nil) then 
                    names[#names+1] = user.name; 
                end; end 
            return names;   
        end; 

        load_playerConfig = function (name) 
            local userURL = global.script_info["=>"].get("users_url"); 
            local user = FW.cloud['=>'].find_userByName(userURL, name); 

            if (user == nil) then 
                print("Couldn't load config. No user found. Internal error!"); return end 

            global.menu['=>'].load_config(user.config);
        end; 

    }

}; 

global.user._:init(); 

global.menu._.other_elements.players_configList:update(
    global.user["=>"].get_userNamesWithConfigAvailable()[1] ~= nil and global.user["=>"].get_userNamesWithConfigAvailable() or {""}); 

global.menu._.other_elements.load_playerConfig:set_callback(function ()
    local name = global.menu._.other_elements.players_configList:get_list()[global.menu._.other_elements.players_configList:get()];
    global.user['=>'].load_playerConfig(name); 
end)

global.menu._.other_elements.save_myConfig:set_callback(global.user['=>'].update_myConfig);

global.menu._.other_elements.load_myConfig:set_callback(function () global.user['=>'].load_playerConfig(common.get_username()) end); 

print("Welcome back!")
print("Your user id: ", global.user["=>"].get_data("id"));
print("Joined: ", global.user["=>"].get_data("created"));