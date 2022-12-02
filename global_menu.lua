global.menu = {

    _ = { 

        create_builder = function (self) 
            local additional_conditions = {"global"}; 
            local condition_list = FW.localPlayer["=>"].get_possibleMovingConditions(); 
            local full_conditionList = FW.array["=>"].pack(additional_conditions, condition_list); 

            self.elements.builder_displayCondition = self.tabs.antiaim_builder:combo("Display condition", full_conditionList);

            for _, condition in pairs (full_conditionList) do 
                local formated_condition = string.format("[\a%s%s\a%s]", self.col, condition, self.def_col); 

                local add = function (name, element) 
                    self.elements[condition..name] = element; 
                    return self.elements[condition..name]; 
                end; 

                if (condition ~= "global") then 
                    add("override", self.tabs.antiaim_builder:switch(string.format("%s Override", formated_condition))); end      

                local in_brackets = function (name)
                    return string.format("[\a%s%s\a%s]", self.col, name, self.def_col); 
                end

                local yaw_randomization = add("yaw_randomization_enable", self.tabs.antiaim_builder:switch(in_brackets("tweak").." Randomize Yaw", false));
                add("yaw_degree", self.tabs.antiaim_builder:slider(in_brackets("global").." Yaw", -180, 180, 0));
                add("modifier_degreeLeft", self.tabs.antiaim_builder:slider(in_brackets("modifier").." Left", -180, 180, 0)); 
                add("modifier_degreeRight", self.tabs.antiaim_builder:slider(in_brackets("modifier").." Right", -180, 180, 0)); 
                add("bodyyaw_addMode", self.tabs.antiaim_builder:combo(in_brackets("body").." Yaw Mode", {"Statical", "Jitter", "Swapping", "Random"}));
                add("bodyyaw_addLeft", self.tabs.antiaim_builder:slider(in_brackets("body").." Left Add", -30, 30, 0)); 
                add("bodyyaw_addRight", self.tabs.antiaim_builder:slider(in_brackets("body").." Right Add", -30, 30, 0)); 
                add("bodyyaw_mode", self.tabs.antiaim_builder:combo(in_brackets("body").." Body Mode", {"Default", "Priority"})); 
                add("bodyyaw_limitLeft", self.tabs.antiaim_builder:slider(in_brackets("body").." Left Limit", 0, 60, 60));  
                add("bodyyaw_limitRight", self.tabs.antiaim_builder:slider(in_brackets("body").." Right Limit", 0, 60, 60)); 
                add("stopoffsetenable", self.tabs.antiaim_builder:switch(in_brackets("tweak").." Stop Offset", false)); 
                add("stopoffsetamount", self.tabs.antiaim_builder:slider(in_brackets("tweak").." Stop Ticks", 0, 200, 100)); 

                local yaw_randomizationTab = yaw_randomization:create(); 
                add("yaw_randomization_mode", yaw_randomizationTab:combo("Mode", {"5-Way", "Normal"})); 
                add("yaw_randomization_limit", yaw_randomizationTab:slider("Limit", 0, 180, 5)); 

                events.render:set(
                    function () 

                        local list = {
                            "override"; 
                            "modifier_degreeRight";
                            "modifier_degreeLeft";
                            "bodyyaw_addRight";
                            "bodyyaw_addLeft";
                            "bodyyaw_limitRight";
                            "bodyyaw_limitLeft";
                            "bodyyaw_addMode";
                            "stopoffsetenable"; 
                            "stopoffsetamount"; 
                            "yaw_degree";
                            "yaw_randomization_enable";
                            "bodyyaw_mode"; 
                        } 

                        local visibility = self.elements.builder_displayCondition:get() == condition; 

                        for _, el in pairs(list) do 
                            local element = self.elements[condition..el]

                            if (element ~= nil) then 
                                element:set_visible(visibility); 
                            end; end 

                    end)

            end; 

        end; 

        create = function (self)
            self.col = "00BFFFFF"
            self.def_col = "8EA3AFFF";
            self.other_elements = {}; 

            --#region tabs

            self.icons = {
                antiaim_builder = ui.get_icon("user-shield"); 
                antiaim_settings = ui.get_icon('wrench');
                antiaim_antibruteforce = ui.get_icon("redo-alt"); 
                antiaim_exploits = ui.get_icon('code'); 

                wifi = ui.get_icon("wifi"); 

            }

            self.tabs = {

            
                antiaim_options = ui.create("Anti Aim", self.icons.antiaim_settings.." Anti Aim [options]");
                antiaim_builder = ui.create("Anti Aim", self.icons.antiaim_builder .. " Anti-Aim [builder]");
                antibruteforce = ui.create("Anti Aim", self.icons.antiaim_antibruteforce .. " Anti-Aim [anti-bruteforce]"); 
                exploits = ui.create("Anti Aim", self.icons.antiaim_exploits .. " Exploits [main]");  

                visuals_main = ui.create("Visuals", "Visuals [global]"); 

                user_main = ui.create("User", "User [configs]"); 

                configs_main = ui.create("User", self.icons.wifi.." Configs [main]");

            }; 

            --#endregion tabs; 



            self.elements = {

                --preset = self.tabs.antiaim_global:combo("Preset", {"Agressive"});

                --self.tabs.user_main:label("Client: " .. get_cheat_username() .. "\n\nSubscription till: Infinity" );
                import_config = self.tabs.user_main:button("      Import Config      "); 
                export_config = self.tabs.user_main:button("      Export Config      "); 

                antibruteforce_enable = self.tabs.antibruteforce:switch("Enable", false);
                antibruteforce_mode = self.tabs.antibruteforce:combo("Main Mode", {"Algorithm", "Statical"});
                antibruteforce_algorithm_desync = self.tabs.antibruteforce:combo("Desync Mode", {"Default", "Low Randomized", "Randomized"});
                antibruteforce_desync_mode = self.tabs.antibruteforce:combo("Override Mode", {"Limit", "Silent"}); 
                antibruteforce_algorithm_side = self.tabs.antibruteforce:combo("Side Mode", {"Missed Side", "Opposite Side"}); 

                prevent_jitter_options = self.tabs.antiaim_options:selectable("Prevent Jitter on", {"No Target", "Target Dormant"});
                prevent_fakelang_options = self.tabs.antiaim_options:selectable("Prevent Fakelag on", {"Exploit Not Charged"});
                on_resolve_actions = self.tabs.antiaim_options:selectable("Resolved Actions", {"Lock Desync"}); 

                enable_indicator = self.tabs.visuals_main:switch("Enable Indicator", false);
                enable_antibrute_notify = self.tabs.visuals_main:switch("Enable Anti-Brute Notify", false);

            }; 

            self.other_elements.players_configList = self.tabs.configs_main:list("Player's Configs", {""});
            self.other_elements.load_playerConfig = self.tabs.configs_main:button(ui.get_icon("user-plus").. " Load"); 
            self.other_elements.save_myConfig = self.tabs.configs_main:button(ui.get_icon("upload").." Save my cfg");
            self.other_elements.load_myConfig = self.tabs.configs_main:button(ui.get_icon('download').." Load my cfg");

            local indicator_subtab = self.elements.enable_indicator:create();  
            local antibruteNotify_subtab = self.elements.enable_antibrute_notify:create(); 

            self.elements.indicator_style = indicator_subtab:combo("Style", {"Legacy", "Default"}); 
            self.elements.indicator_color = indicator_subtab:color_picker("Color", color(255, 255, 255, 255));
            self.elements.indicator_dt_color = indicator_subtab:color_picker("DT Color", color(255, 255, 0, 255));

            self.elements.antibrute_color = antibruteNotify_subtab:color_picker("Color", color(0, 230, 255, 255));
            self.elements.antibrute_reset_color = antibruteNotify_subtab:color_picker("Reset Color",  color(0, 230, 255, 255));

            self.elements.break_lagcomp = self.tabs.exploits:switch("Break Lagcomp", false); 
            local exploit_subtab = self.elements.break_lagcomp:create(); 

            self.elements.lagcomp_distance = exploit_subtab:slider("Distance", 10, 500, 150);
            self.elements.lagcomp_strength = exploit_subtab:slider("Strength", 1, 6, 2);

            self.tooltips = {

                self.elements.antibruteforce_enable:set_tooltip("Antibruteforce is modules that doesn't allow resolvers to 'bruteforce' your angles with data from last miss. \nBasically in most cases enemy will miss again.");

            }
            self:create_builder(); 
            

        end;  

        config_system = {

            ["save"] = function (to_clipboard) 
                local config = {}; 

                for name, element in pairs(global.menu._.elements) do 
                    if (element:get_type() ~= "label" and element:get_type() ~= "button") then 

                        config[name] = element:get(); 
                    
                    end; end  

                --// nice json library. panorama saved me once more [fix json.stringify];
                local config_stringEncrypted = encoder.encode(FW.panorama["=>"].json.stringify(config)); 
                    
                if (to_clipboard == true) then 
                    FW.console["=>"].color_print({color(255, 255, 255, 255), color(20, 180, 255, 255)}, true,
                    {"[", "source.h&&", "] Config ", "succesfully&&", " saved to ", "clipboard&&", "."}); 
                    clipboard.set(config_stringEncrypted); end 

                return config_stringEncrypted; 
            end;  

            ["load"] = function (config)  
                local load_failed = function (reason) 
                    FW.console["=>"].color_print({color(255, 255, 255, 255), color(255, 255, 0, 255)}, true,
                    {"[", "source.h&&", "] Config load", " failed&&", " [", reason.."&&", "]"}); 
                end

                if (config == nil or config == "") then 
                    load_failed("empty string"); return end 
    
                local decoded_config = encoder.decode(config); 

                local cfg = FW.panorama["=>"].json.parse(decoded_config); 

                if (cfg == nil or cfg == "null") then 
                    load_failed("incorrect config"); return end 

                for element_name, value in pairs(cfg) do 
                    if (global.menu._.elements[element_name] ~= nil) then 

                        global.menu._.elements[element_name]:set(value); 

                    end; end 

                FW.console["=>"].color_print({color(255, 255, 255, 255), color(20, 180, 255, 255)}, true,
                {"[", "source.h&&", "] Config ", "loaded", " succesfully&&", "."});
            end; 

        }
    
    }; 

    ["=>"] = {

        get_elements = function () 
            return global.menu._.elements; 
        end;

        save_config = function (to_clipboard) 
            return global.menu._.config_system.save(to_clipboard); 
        end; 

        load_configFromClipboard = function ()
            global.menu._.config_system.load(clipboard.get()); 
        end; 

        load_config = function (cfg)
            global.menu._.config_system.load(cfg); 
        end

    }

}

global.menu._:create(); 

global.menu._.elements.export_config:set_callback(function () global.menu["=>"].save_config(true) end);
global.menu._.elements.import_config:set_callback(global.menu['=>'].load_configFromClipboard);