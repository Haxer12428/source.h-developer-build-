--//registering all variables from api, lua 
local sin = math.sin; 
local execute_after, memInfo, get_threat, get_local_player = utils.execute_after, gcinfo, entity.get_threat, entity.get_local_player; 
local get_net_channel = utils.net_channel; 
local random_int, key_hold = utils.random_int, common.is_button_down; 
local draw = {}; 
draw.rect, draw.line, draw.text, draw.rect_outline = render.rect, render.line, render.text, render.rect_outline; 
local FW = {}; 
FW.angles = {}; 
FW.localPlayer = {}; 
FW.wGL = {}; 
FW.GL = {}; 
FW.userInput = {};

local global = {}; 
global.gui = {}; 
