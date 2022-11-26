FW.ffi = {

    _ = {
        storage = {}; 

        related_functions = {
                
            this_call = function(call_function, parameters)
                return function(...)
                    return call_function(parameters, ...)
                end
            end; 

        }; 

        init = function (self) 
            local ffi = require("ffi");

            ffi.cdef[[
                // csa
                typedef void*(__thiscall* get_client_entity_t)(void*, int);

                // color print 
                typedef struct
                {
                    uint8_t r;
                    uint8_t g;
                    uint8_t b;
                    uint8_t a;
                } color_struct_t;
                typedef void (__cdecl* print_function)(void*, color_struct_t&, const char* text, ...);

                // download 
                void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK);
            ]]

            local urlmon = ffi.load('UrlMon')
            local wininet = ffi.load('WinInet')


            self.storage = { 
                uintptr_t = ffi.typeof("uintptr_t**"); 
                
                --// color print 
                color_struct_t = ffi.typeof("color_struct_t");
                
                --//download 
                urlmon = urlmon;
                wininet = wininet; 
            }

            self.storage.entity_list_003 = ffi.cast(self.storage.uintptr_t, utils.create_interface("client.dll", "VClientEntityList003"));
            self.storage.get_entity_address = self.related_functions.this_call(ffi.cast("get_client_entity_t", self.storage.entity_list_003[0][3]), self.storage.entity_list_003)
            
            --// color print 
            self.storage.colorPrintInterface = ffi.cast(self.storage.uintptr_t, utils.create_interface("vstdlib.dll", "VEngineCvar007")); 
            self.storage.colorPrintFunction = ffi.cast("print_function", self.storage.colorPrintInterface[0][25]);


            self.storage.engineClient = utils.create_interface("engine.dll", "VEngineClient014");
            self.storage.engineClientClass = ffi.cast(ffi.typeof("void***"), self.storage.engineClient);
            self.storage.isConsoleVisible = ffi.cast("bool(__thiscall*)(void*)", self.storage.engineClientClass[0][11]);

        end;

    }; 

    ["=>"] = {

        get = function () 
            return FW.ffi._.storage; 
        end; 

    }

}; 

FW.ffi._:init(); 