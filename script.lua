--//registering all variables from api, lua 
local sin = math.sin; 
local execute_after, memInfo, get_threat, get_local_player = utils.execute_after, gcinfo, entity.get_threat, entity.get_local_player; 
local get_net_channel = utils.net_channel; 
local random_int, key_hold = utils.random_int, common.is_button_down; 
local draw = {}; 
draw.rect, draw.line, draw.text, draw.rect_outline = render.rect, render.line, render.text, render.rect_outline; 
draw.blur, draw.poly, draw.poly_blur, draw.poly_line, draw.gradient, draw.cricle, draw.cricle_outline, draw.cricle_gradient, draw.circle_3d = render.blur, render.poly, render.poly_blur, render.poly_line, render.gradient, render.cricle, render.cricle_outline, render.cricle_gradient, render.circle_3d
local FW = {}; 
FW.angles = {}; 
FW.localPlayer = {}; 
FW.wGL = {}; 
FW.GL = {}; 
FW.userInput = {};

local global = {}; 
global.gui = {}; 
