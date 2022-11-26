global.visuals = {

    _ = {

        under_crossair = {

            styles = {
                cache = { last_exploit = "" }; 

                Legacy = function (self, arguments) 
                    local global_alpha = FW.animate["=>"]:basic("$Indicator Alpha", 1000, 0, arguments.enabled and 255 or 0);

                    if (global_alpha < 1) then 
                        return end 

                    local color = function (r, g, b, a) 
                        return color(r, g, b, a):alpha_modulate(math.min(global_alpha, a));
                    end; 

                    arguments.color = arguments.color:alpha_modulate(math.min(global_alpha, arguments.color.a));

                    local screen_size = get_screen_size()/2;
                    local position = screen_size + vector(0, 40); 
                    
                    local script_name = global.script_info["=>"].get('name'); 
                    local script_build = global.script_info["=>"].get('build'); 
                    local inverterState = FW.angles["=>"].get_inverter(); 

                    local font = FW.fonts["=>"].get("Smallest Pixel-7", 10, "oda"); 

                    local script_nameSize = measure_text(font, nil, script_name);  

                    render.text(
                        font,
                        position,
                        color(255, 255, 255, 255),
                        nil,
                        script_name
                    ) 

                    local build_alpha = math.min(math.floor(math.sin((globals.realtime%4) * 3) * 100), 255);
                    build_alpha = math.min(global_alpha, build_alpha); 

                    render.text(
                        font, 
                        position + vector(1 + script_nameSize.x,0),
                        arguments.color:alpha_modulate(build_alpha),
                        nil, 
                        script_build
                    ) 

                    render.text(
                        font,
                        position + vector(0, 9), 
                        color(0, 120, 200, 255),
                        nil,
                        FW.localPlayer['=>'].info().move_state..":"
                    ) 

                    local body_yawSize = measure_text(font, nil, FW.localPlayer['=>'].info().move_state..":"); 

                    render.text(
                        font,
                        position + vector(body_yawSize.x, 9),
                        color(255, 255, 255, 255),
                        nil,
                        inverterState and "R" or "L"
                    ) 

                    --//key binds

                    local keybinds_startPosition = 18; 
                    local exploit_startPosition = 18; 

                    local exploit_enabled = FW.GameVars["=>"]:get_enabledExploit(); 
                    local final_keybindsPosition = exploit_enabled == nil and 18 or 18 + 9; 

                    if (exploit_enabled == "HS") then exploit_enabled = "ONSHOT"; end 

                    keybinds_startPosition = FW.animate['=>']:basic("$KeybindsInd", 100, keybinds_startPosition, final_keybindsPosition); 
                    local exploit_alpha = FW.animate["=>"]:basic("$KeybindsA", 1000, 0, exploit_enabled ~= nil and 255 or 0); 
                    exploit_alpha = math.min(global_alpha, exploit_alpha); 

                    if (exploit_enabled ~= nil) then self.cache.last_exploit = exploit_enabled; end 

                    local exploit_color = exploit_enabled == "DT" and global.menu['=>'].get_elements().indicator_dt_color:get() or color(200, 255, 255, 255);
                    if (rage.exploit:get() ~= 1) then exploit_color = color(255, 0, 0, 255); end 

                    --// render exploit 
                    render.text(
                        font,
                        position + vector(0, exploit_startPosition),
                        exploit_color:alpha_modulate(exploit_alpha),
                        nil, 
                        self.cache.last_exploit
                    );  

                    

                    local active_list = {
                        {"BAIM", FW.GameVars['=>']:is_baiming()}; 
                        {"SP", FW.GameVars["=>"]:is_safepointing()}; 
                        {"MD", FW.GameVars['=>'].find_bindByName("Minimum Damage") ~= nil and true or false}; 
                    }; 

                    local bind_add_x = 0; 

                    for _, object in pairs(active_list) do 
                        local val = object[2]; 
                        local name = object[1]; 

                        local alpha = FW.animate['=>']:basic(name.."IndicatorKey", 1400, 100, val and 255 or 80);
                        alpha = math.min(global_alpha, alpha); 

                        render.text(
                            font,
                            position + vector(bind_add_x, keybinds_startPosition),
                            arguments.color:alpha_modulate(alpha),
                            nil,
                            name
                        )

                        bind_add_x = bind_add_x + render.measure_text(font, nil, name).x + 1; 
                    end; 

                end; 

                Default = function (self, arguments) 
                    local global_alpha = FW.animate["=>"]:basic("$Indicator Alpha", 1000, 0, arguments.enabled and 255 or 0);

                    if (global_alpha < 1) then 
                        return end 

                    local clr = function (r, g, b, a) 
                        if (r ~= nil and g == nil) then 
                            return r:alpha_modulate(math.min(r.a, global_alpha)); end 
                        return color(r, g, b, math.min(a, global_alpha)); 
                    end;    

                    local v = render.screen_size()/2 + vector(0, 50); 
                    local name_font = FW.fonts['=>'].get("Verdana", 10, 'baod'); 
                    local script_name = global.script_info['=>'].get("name"); 
                    local name_size = vector(render.measure_text(name_font, nil, script_name).x, 0); 

                    render.text(
                        name_font, 
                        v - name_size/2, 
                        clr(arguments.color),
                        nil,
                        script_name
                    ); 

                    local antibruteforce_timeLeft = global.antiaim['=>'].get_antibruteforceTimeLeft(); 
                    local maximum_antibruteforceTime = global.antiaim['=>'].get_antibruteforceInfo("reset_after"); 
                    local antibruteforce_enabled = global.antiaim['=>'].get_antibruteforceInfo('enabled'); 
                    local antibruteforce_bar = antibruteforce_enabled and antibruteforce_timeLeft > 0 and true or false; 
                    local antibruteforce_factor = math.min(1, math.max(0, antibruteforce_timeLeft/maximum_antibruteforceTime)); 

                    local desync_delta = FW.math['=>'].round(math.abs(FW.angles["=>"].get_desyncDelta()), 1); 
                    local maximum_desyncDelta = FW.angles['=>'].get_maximumDesync(); 
                    local desync_factor = math.min(1, math.max(0, desync_delta/maximum_desyncDelta)); 


                    local bar_lenght = vector(name_size.x, 4); 
                    local bar_position = v + vector(-bar_lenght.x/2 + 1, 13); 
                    local bar_rounding = 3; 
                    local bar_fill = FW.animate['=>']:basic("$indicatorBarFIll", 2, 0, (antibruteforce_enabled and antibruteforce_factor or desync_factor)); 

                    render.rect(
                        bar_position,
                        bar_position + bar_lenght,
                        clr(0, 0, 0, 255),
                        bar_rounding
                    )

                    render.rect(
                        bar_position + vector(1, 1),
                        bar_position + vector(bar_lenght.x*bar_fill, bar_lenght.y) - vector(1, 1),
                        clr(arguments.color),
                        bar_rounding
                    )

                    local move_stateFont = FW.fonts["=>"].get("Smallest Pixel-7", 10, "oda"); 
                    local move_state = string.upper(FW.localPlayer['=>'].info().move_state);  

                    render.text(
                        move_stateFont,
                        v + vector(0, 16) - vector(render.measure_text(move_stateFont, nil, move_state).x/2 - 1, 0), 
                        clr(255, 255, 255, 100),
                        nil,
                        move_state
                    ); 

                    local exploit_enabled = FW.GameVars['=>']:get_enabledExploit(); 
                    if (exploit_enabled == nil) then 
                        return end 
                    
                    local dt_color = global.menu['=>'].get_elements().indicator_dt_color:get(); 
                    local exploit_color = exploit_enabled == "DT" and clr(dt_color) or clr(0, 220, 255, 255); 
                    if (rage.exploit:get() ~= 1) then exploit_color = clr(255, 0, 0, 255); end 
                    
                    render.text(
                        move_stateFont,
                        v + vector(-render.measure_text(move_stateFont, nil, exploit_enabled).x/2 + 1, 25), 
                        exploit_color,
                        nil,
                        exploit_enabled
                    )
                end; 

            }; 

            main = function (self) 
                local menu_elements = global.menu["=>"].get_elements();     
                local enabled = menu_elements.enable_indicator:get(); 

                if (FW.localPlayer["=>"]:is_alive() ~= true) then 
                    enabled = false; end 

                
                local arguments = {
                    color = menu_elements.indicator_color:get();
                    enabled = enabled;
                }

                local style = menu_elements.indicator_style:get(); 

                self.styles[style](self.styles, arguments); 
            end; 
        };

        log_system = {

            antibruteforce = {

                switch = function (args) 
                    if (not global.menu['=>'].get_elements().enable_antibrute_notify:get()) then 
                        return end 

                    local clr = global.menu['=>'].get_elements().antibrute_color:get(); 
                    local script_name = global.script_info['=>'].get("name"); 
                        
                    FW.log['=>'].new(
                        color(255, 255, 255, 255),
                        clr,
                        {"[", script_name..'&&', "]", " Switched anti-brute due to enemy miss at you."}
                    )
                end; 

                reset = function (args) 
                    if (not global.menu['=>'].get_elements().enable_antibrute_notify:get()) then 
                        return end 

                    local clr = global.menu['=>'].get_elements().antibrute_reset_color:get(); 
                    local script_name = global.script_info['=>'].get("name"); 

                    FW.log['=>'].new(
                        color(255, 255, 255, 255),
                        clr,    
                        {'[', script_name..'&&', "] Reseted anti-brute data."} 
                    )
                end; 

            }

        }; 

        init = function (self) 

            events.render:set(
                function () 
                    self.under_crossair:main(); 
                end)

            events.antibruteforce_switch:set(
                function (args)
                    self.log_system.antibruteforce.switch(args); 
                end)

            events.antibruteforce_reset:set(
                function (args)
                    self.log_system.antibruteforce.reset(args);
                end)

        end; 
    }; 

}; 

global.visuals._:init();