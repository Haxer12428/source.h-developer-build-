--//registering all variables from api, lua 
local sin = math.sin; 
local execute_after, memInfo, get_threat, get_local_player = utils.execute_after, gcinfo, entity.get_threat, entity.get_local_player; 
local get_net_channel = utils.net_channel; 
local FW = {}; 
FW.angles = {}; 
FW.localPlayer = {}; 