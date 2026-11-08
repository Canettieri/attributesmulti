-- Run from the addon root with Lua 5.1. WoW security itself needs an in-game test.
local frames, registered, combat = {}, nil, false
local hover, calls = nil, 0
UIParent, CharacterMicroButton = {}, {}
UIParent.GetEffectiveScale = function() return 1 end
issecretvalue = function() return true end
InCombatLockdown = function() return combat end
ToggleCharacter = function(tab) assert(tab == "PaperDollFrame"); calls = calls + 1 end
local function NewFrame(name, parent, template)
	local frame = { name = name, parent = parent, template = template, shown = true, scripts = {}, attrs = {}, events = {}, wraps = {} }
	function frame:GetName() return self.name end
	function frame:GetFrameStrata() return self.strata or "FULLSCREEN" end
	function frame:GetFrameLevel() return self.level or 3 end
	function frame:IsShown() return self.shown or false end
	function frame:IsVisible() return self.visible or false end
	function frame:GetRect() return self.left or 10, 20, self.width or 100, 16 end
	function frame:GetEffectiveScale() return self.scale or 1 end
	function frame:SetAllPoints() error("Secure overlay must not anchor to Titan") end
	function frame:ClearAllPoints() self.point = nil end
	function frame:SetPoint(...) self.point = { ... } end
	function frame:SetSize(width, height) self.size = { width, height } end
	function frame:SetFrameStrata(value) self.strata = value end
	function frame:SetFrameLevel(value) self.level = value end
	function frame:RegisterForClicks(...) self.clicks = { ... } end
	function frame:SetPassThroughButtons(...) self.pass = { ... } end
	function frame:SetAttribute(key, value) self.attrs[key] = value end
	function frame:SetShown(value) self.shown = value end
	function frame:SetScript(key, value) self.scripts[key] = value end
	function frame:GetScript(key) return self.scripts[key] end
	function frame:RegisterEvent(event) self.events[event] = true end
	function frame:UnregisterAllEvents() self.events = {} end
	frames[#frames + 1] = frame
	return frame
end
CreateFrame = function(_, name, parent, template) return NewFrame(name, parent, template) end
RegisterStateDriver = function(frame, state, condition) frame.driver = { state, condition } end
SecureHandlerWrapScript = function(frame, script, control, snippet)
	error("Secure overlay must not wrap Titan scripts")
end
LibStub = function(name)
	if name == "Elib-4.0" then
		return { Register = function(config)
			registered = config
			local frame = NewFrame("TitanPanelTestButton")
			frame:SetScript("OnEnter", function(self) hover = self end)
			frame:SetScript("OnLeave", function(self) assert(self == hover); hover = nil end)
			return frame
		end }
	end
	return { GetLocale = function() return {} end }
end
local L = {}
assert(loadfile("Core/AttributesCore.lua"))("TitanAttributesMulti", L)
local frame = L.Elib({ characterClick = true })
local click = assert(frame.characterClick)
assert(registered.onClick == nil and calls == 0)
assert(click.parent == UIParent and click.anchor == nil and click.level == 4)
assert(click.attrs["*type1"] == "click" and click.attrs["*clickbutton1"] == CharacterMicroButton)
assert(click.attrs.useOnKeyDown == false and click.clicks[1] == "LeftButtonUp")
assert(click.pass[1] == "RightButton" and click.pass[2] == "MiddleButton")
assert(click.shown == false and next(frame.wraps) == nil)
local watcher = frames[#frames]
-- Titan finishes registration later, after the overlay's initial visibility.
frame.visible, frame.level, frame.strata = true, 10, "DIALOG"
watcher.scripts.OnUpdate(nil, 0.1)
assert(click.shown and click.level == 11 and click.strata == "DIALOG")
assert(click.point[2] == UIParent and click.point[4] == 10 and click.size[1] == 100)
frame.scale, frame.left, frame.width = 0.8, 50, 120
watcher.scripts.OnUpdate(nil, 0.1)
assert(click.point[4] == 40 and click.point[5] == 16 and click.size[1] == 96)
frame.visible = false
combat = true
watcher.scripts.OnUpdate(nil, 0.1)
assert(click.shown) -- No insecure protected-frame mutations in combat.
assert(click.attrs["*type1"] == "click" and click.driver == nil)
combat = false
watcher.scripts.OnUpdate(nil, 0.1)
assert(not click.shown)
click.scripts.OnEnter(); assert(hover == frame)
click.scripts.OnLeave(); assert(hover == nil)
assert(click.attrs["_onstate-combat"] == nil)
combat = true
local deferred = L.Elib({ characterClick = true })
assert(deferred.characterClick == nil)
local pending = frames[#frames]
assert(pending.events.PLAYER_REGEN_ENABLED)
combat = false
pending.scripts.OnEvent()
assert(deferred.characterClick and next(pending.events) == nil)
issecretvalue = nil
L.Elib({ characterClick = true })
registered.onClick(nil, "RightButton"); assert(calls == 0)
registered.onClick(nil, "LeftButton"); assert(calls == 1)
L.Elib({}); assert(registered.onClick == nil)
print("Character click tests passed")
