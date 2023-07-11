local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PORTRAIT_UPDATE");
f:RegisterEvent("PORTRAITS_UPDATED");
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, arg1) end)

local prefix = "hud-microbutton-";
	
local function replaceAtlases(self, name)
    -- code from 9.2 version of FrameXML\MainMenuBarMicroButtons.lua
    self:SetNormalAtlas(prefix..name.."-Up", true);
	self:SetPushedAtlas(prefix..name.."-Down", true);
	self:SetDisabledAtlas(prefix..name.."-Disabled", true);
	self:SetHighlightAtlas("hud-microbutton-highlight");
    
    local normalTexture = self:GetNormalTexture();
	if(normalTexture) then 
		normalTexture:SetAlpha(1); 
	end
    if(self.FlashContent) then 
		UIFrameFlashStop(self.FlashContent);
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

local texture = CharacterMicroButton:CreateTexture("MicroButtonPortrait", "OVERLAY")
texture:SetPoint("TOP", 0, -6)
texture:SetSize(10, 16)
texture:SetTexCoord(0.2, 0.8, 0.0666, 0.9)

local function replaceAllAtlases()
    for _, data in pairs(buttons) do
        replaceAtlases(data.button, data.name)
    end
    SetPortraitTexture(MicroButtonPortrait, "player")
end
replaceAllAtlases()

f:HookScript("OnEvent", function()
    replaceAllAtlases()
end)

CharacterMicroButton:HookScript("OnEvent", function()
    SetPortraitTexture(MicroButtonPortrait, "player")
end)

local function CharacterMicroButton_SetPushed()
    SetPortraitTexture(MicroButtonPortrait, "player")
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
	CharacterMicroButton:SetButtonState("PUSHED", true);
end
local function CharacterMicroButton_SetNormal()
    SetPortraitTexture(MicroButtonPortrait, "player")
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
	CharacterMicroButton:SetButtonState("NORMAL");
end

CharacterMicroButton:HookScript("OnMouseDown", function(self)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( self.down ) then
            CharacterMicroButton_SetPushed();
		else
			
		end
	end
end)
CharacterMicroButton:HookScript("OnMouseUp", function(self, button)
	if ( KeybindFrames_InQuickKeybindMode() ) then
	else
		if ( self.down ) then
		elseif ( self:GetButtonState() == "NORMAL" ) then
			CharacterMicroButton_SetNormal();
		else
			CharacterMicroButton_SetPushed();
		end
	end
end)

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
    replaceAllAtlases()
end)

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

local function GuildMicroButton_UpdateTabard()
    local self = GuildMicroButton
	local tabard = GuildMicroButtonTabard;

	-- switch textures if the guild has a custom tabard
	local emblemFilename = select(10, GetGuildLogoInfo());
	if ( emblemFilename ) then
		--if ( not tabard:IsShown() ) then
			self:SetNormalAtlas("hud-microbutton-Character-Up", true);
			self:SetPushedAtlas("hud-microbutton-Character-Down", true);
            self:GetNormalTexture():SetVertexColor(1, 1, 1)
            self:GetPushedTexture():SetVertexColor(1, 1, 1)
            self.Emblem:Hide()
            self.HighlightEmblem:Hide()
			-- no need to change disabled texture, should always be available if you're in a guild
			tabard:Show();
		--end
        SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background);
	else
		if ( tabard:IsShown() ) then
			self:SetNormalAtlas("hud-microbutton-Socials-Up", true);
			self:SetPushedAtlas("hud-microbutton-Socials-Down", true);
			self:SetDisabledAtlas("hud-microbutton-Socials-Disabled", true);
			tabard:Hide();
		end
	end
end
GuildMicroButton_UpdateTabard()
C_Timer.After(4, GuildMicroButton_UpdateTabard)

local function updateButtons()
    if ( CharacterFrame and CharacterFrame:IsShown() ) then
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton_SetNormal();
	end
    GuildMicroButton_UpdateTabard()
    if ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, -2);
		GuildMicroButtonTabard:SetAlpha(0.70);
	else
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1);
		GuildMicroButtonTabard:SetAlpha(1);
    end
end

hooksecurefunc("UpdateMicroButtons", updateButtons)
hooksecurefunc(GuildMicroButton, "UpdateTabard", GuildMicroButton_UpdateTabard)

hooksecurefunc(GuildMicroButton, "SetPushed", function()
    GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, -2);
	GuildMicroButtonTabard:SetAlpha(0.70);
end)
