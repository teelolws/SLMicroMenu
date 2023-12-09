local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PORTRAIT_UPDATE");
f:RegisterEvent("PORTRAITS_UPDATED");
f:RegisterEvent("PLAYER_ENTERING_WORLD")

local prefix = "hud-microbutton-";
	
local function replaceAtlases(self, name)
    -- code from 9.2 version of FrameXML\MainMenuBarMicroButtons.lua
    self:SetNormalAtlas(prefix..name.."-Up", true)
    self:SetPushedAtlas(prefix..name.."-Down", true)
    
    if self == GuildMicroButton then
        local tabard = GuildMicroButtonTabard;

        -- switch textures if the guild has a custom tabard
        local emblemFilename = select(10, GetGuildLogoInfo());
        if ( emblemFilename ) then
            self:SetNormalAtlas("hud-microbutton-Character-Up", true)
            self:SetPushedAtlas("hud-microbutton-Character-Down", true)
            self:GetNormalTexture():SetVertexColor(1, 1, 1)
            self:GetPushedTexture():SetVertexColor(1, 1, 1)
            self.Emblem:Hide()
            self.HighlightEmblem:Hide()
			tabard:Show()
            SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background)
        else
            self:SetNormalAtlas("hud-microbutton-Socials-Up", true)
            self:SetPushedAtlas("hud-microbutton-Socials-Down", true)
            self:SetDisabledAtlas("hud-microbutton-Socials-Disabled", true)
            tabard:Hide()
        end
    end
    
	self:SetDisabledAtlas(prefix..name.."-Disabled", true)
	self:SetHighlightAtlas("hud-microbutton-highlight")
    
    local normalTexture = self:GetNormalTexture();
	if(normalTexture) then 
		normalTexture:SetAlpha(1); 
	end
    if(self.FlashContent) then 
		self.FlashContent:SetAtlas(prefix..name.."-Up", true)
	end
end

local buttons = {
    {button = CharacterMicroButton, name = "Character"},
    {button = SpellbookMicroButton, name = "Spellbook"},
    {button = TalentMicroButton, name = "Talents"},
    {button = AchievementMicroButton, name = "Achievement"},
    {button = QuestLogMicroButton, name = "Quest"},
    {button = GuildMicroButton, name = "Socials"},
    {button = LFDMicroButton, name = "LFG"},
    {button = CollectionsMicroButton, name = "Mounts"},
    {button = EJMicroButton, name = "EJ"},
    {button = StoreMicroButton, name = "BStore"},  
    {button = MainMenuMicroButton, name = "MainMenu"},
}

local function replaceAllAtlases()
    for _, data in pairs(buttons) do
        replaceAtlases(data.button, data.name)
    end
end

f:SetScript("OnEvent", replaceAllAtlases)

MainMenuMicroButton:CreateTexture("MainMenuBarDownload", "OVERLAY")
MainMenuBarDownload:SetPoint("BOTTOM", "MainMenuMicroButton", "BOTTOM", 0, 7)
MainMenuBarDownload:SetSize(28, 28)

MainMenuMicroButton:HookScript("OnUpdate", function(self, elapsed)
    local status = GetFileStreamingStatus();
        if ( status == 0 ) then
    	MainMenuBarDownload:Hide();
    else
    	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Up");
    	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Down");
    	self:SetDisabledTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Up");
    	if ( status == 1 ) then
    		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Green");
    	elseif ( status == 2 ) then
    		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Yellow");
    	elseif ( status == 3 ) then
    		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Red");
    	end
    	MainMenuBarDownload:Show();
    end
    replaceAtlases(MainMenuMicroButton, "MainMenu")
end)

local eventTypes = {"OnEnter", "OnClick", "OnMouseDown", "OnMouseUp", "OnLeave"}
for _, data in pairs(buttons) do
    for _, eventType in pairs(eventTypes) do
        data.button:HookScript(eventType, function()
            replaceAtlases(data.button, data.name)
        end)
    end    
end

CreateFrame("Frame", "GuildMicroButtonTabard", GuildMicroButton)
GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1)
GuildMicroButtonTabard:SetPoint("BOTTOMRIGHT", -3, -1)

GuildMicroButtonTabard.background = GuildMicroButtonTabard:CreateTexture("GuildMicroButtonTabardBackground", "ARTWORK")
GuildMicroButtonTabardBackground:SetAtlas("hud-microbutton-Guild-Banner", true)
GuildMicroButtonTabardBackground:SetPoint("CENTER", 0, 0)

GuildMicroButtonTabard.emblem = GuildMicroButtonTabard:CreateTexture("GuildMicroButtonTabardEmblem", "OVERLAY")
GuildMicroButtonTabardEmblem:SetMask("Interface\GuildFrame\GuildEmblems_01")
GuildMicroButtonTabardEmblem:SetSize(14, 14)
GuildMicroButtonTabardEmblem:SetPoint("CENTER", 0, 0)

-- move tabard with button press
local function updateButtons()
    if ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, -2);
		GuildMicroButtonTabard:SetAlpha(0.70);
	else
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1);
		GuildMicroButtonTabard:SetAlpha(1);
    end
end

hooksecurefunc("UpdateMicroButtons", updateButtons)

-- this is needed because there is a slight delay between button press and guild frame being visible. Button appears pushed before the guild frame is visible, without this, the tabard doesn't move cleanly with the rest of the button.
hooksecurefunc(GuildMicroButton, "SetPushed", function()
    GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, -2);
	GuildMicroButtonTabard:SetAlpha(0.70);
end)
