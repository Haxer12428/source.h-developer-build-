FW.panorama = {

    ["=>"] = {

        json = panorama.loadstring([[
            return {
                stringify: JSON.stringify,
                parse: JSON.parse
            };
        ]], "CSGOMainMenu")();

        http = panorama.loadstring([[
            return {
                request: function(url, options){
                    $.AsyncWebRequest(url, options);
                }
            }
        ]])(); 

        https = http_lib.new({
            task_interval = 0.3, -- polling intervals
            enable_debug = false, -- print http request s to the console
            timeout = 10 -- request expiration time
        }); 

    }

}