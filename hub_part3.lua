-- DeltaHub PARTE 3: UI Principal
local T        = _G.DH.T
local makeFrame= _G.DH.makeFrame
local makeLbl  = _G.DH.makeLbl
local makeBtn  = _G.DH.makeBtn
local makeScroll=_G.DH.makeScroll
local notify   = _G.DH.notify
local player   = _G.DH.player
local TS       = _G.DH.TS
local SGui     = _G.DH.ScreenGui

-- ======= JANELA PALETA =======
local PaletteWindow = makeFrame(SGui, UDim2.new(0,220,0,300), UDim2.new(0.5,-110,0.5,-150),
    Color3.fromRGB(13,13,18), 300)
PaletteWindow.Visible = false
local PalTBar,_ = makeFrame(PaletteWindow, UDim2.new(1,0,0,36), UDim2.new(0,0,0,0), Color3.fromRGB(20,20,28), 301)
makeLbl(PalTBar,"🎨 Paleta",UDim2.new(1,-40,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local BtnPalClose=makeBtn(PalTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),302)
BtnPalClose.MouseButton1Click:Connect(function() PaletteWindow.Visible=false end)
local PalScroll=makeScroll(PaletteWindow,UDim2.new(1,-8,1,-44),UDim2.new(0,4,0,40),301)
local COLORS={
    {"🟣 Roxo",Color3.fromRGB(110,60,255)},
    {"🔵 Azul",Color3.fromRGB(0,140,255)},
    {"🟢 Verde",Color3.fromRGB(0,200,100)},
    {"🔴 Vermelho",Color3.fromRGB(220,50,50)},
    {"🟡 Dourado",Color3.fromRGB(255,190,0)},
    {"⚪ Branco",Color3.fromRGB(220,220,220)},
    {"🌈 RGB",nil},
}
for _,c in ipairs(COLORS) do
    local cb=makeBtn(PalScroll,c[1],UDim2.new(1,0,0,34),nil,302)
    cb.TextSize=12
    cb.MouseButton1Click:Connect(function()
        _G.DH.borderMode = c[2] and "custom" or "rgb"
        _G.DH.customColor = c[2]
        if c[2] then
            if _G.DH.border then _G.DH.border.Color=c[2] end
        end
        _G.DH.saveConfig(_G.DH.lang, c[2] and "custom" or "rgb")
        PaletteWindow.Visible=false
    end)
end
_G.DH.PaletteWindow=PaletteWindow

-- ======= JANELA IDIOMA =======
local LangWindow=makeFrame(SGui,UDim2.new(0,200,0,230),UDim2.new(0.5,-100,0.5,-115),
    Color3.fromRGB(13,13,18),300)
LangWindow.Visible=false
local LangTBar,_=makeFrame(LangWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
makeLbl(LangTBar,"🌍 Idioma",UDim2.new(1,-40,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local BtnLangClose=makeBtn(LangTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),302)
BtnLangClose.MouseButton1Click:Connect(function() LangWindow.Visible=false end)
local LANGS={{"🇧🇷 Português","pt_BR"},{"🇺🇸 English","en_US"},{"🇪🇸 Español","es_ES"},{"🇯🇵 日本語","ja_JP"}}
local LangScroll=makeScroll(LangWindow,UDim2.new(1,-8,1,-44),UDim2.new(0,4,0,40),301)
for _,l in ipairs(LANGS) do
    local lb=makeBtn(LangScroll,l[1],UDim2.new(1,0,0,38),nil,302)
    lb.TextSize=12
    lb.MouseButton1Click:Connect(function()
        _G.DH.lang=l[2]
        _G.DH.saveConfig(l[2],_G.DH.borderMode)
        LangWindow.Visible=false
        if _G.DH.refreshUI then _G.DH.refreshUI() end
    end)
end
_G.DH.LangWindow=LangWindow

-- ======= JANELA YARHM =======
local YARHMWindow=makeFrame(SGui,UDim2.new(0,300,0,160),UDim2.new(0.5,-150,0.5,-80),
    Color3.fromRGB(13,13,18),300)
YARHMWindow.Visible=false
local YTBar,_=makeFrame(YARHMWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
local YTLbl=makeLbl(YTBar,T("yarhm_confirm"),UDim2.new(1,-20,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local YDescLbl=makeLbl(YARHMWindow,T("game_yarhm"),UDim2.new(1,-20,0,34),UDim2.new(0,10,0,44),301,Enum.TextXAlignment.Left,Color3.fromRGB(160,155,200),12)
YDescLbl.TextWrapped=true
local BtnYRun=makeBtn(YARHMWindow,T("game_run"),UDim2.new(0,120,0,34),UDim2.new(0,10,1,-44),302)
local BtnYCancel=makeBtn(YARHMWindow,T("del_cancel"),UDim2.new(0,120,0,34),UDim2.new(1,-130,1,-44),302)
BtnYCancel.MouseButton1Click:Connect(function() YARHMWindow.Visible=false end)
BtnYRun.MouseButton1Click:Connect(function()
    YARHMWindow.Visible=false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Roblox-MM2-Script/main/MM2%20Script.lua",true))()
end)
_G.DH.YARHMWindow=YARHMWindow

-- ======= JANELA IY =======
local IYWindow=makeFrame(SGui,UDim2.new(0,300,0,160),UDim2.new(0.5,-150,0.5,-80),
    Color3.fromRGB(13,13,18),300)
IYWindow.Visible=false
local IYTBar,_=makeFrame(IYWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
makeLbl(IYTBar,T("iy_confirm"),UDim2.new(1,-20,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local IYDescLbl=makeLbl(IYWindow,T("game_iy_script"),UDim2.new(1,-20,0,34),UDim2.new(0,10,0,44),301,Enum.TextXAlignment.Left,Color3.fromRGB(160,155,200),12)
IYDescLbl.TextWrapped=true
local BtnIYRun=makeBtn(IYWindow,T("game_run"),UDim2.new(0,120,0,34),UDim2.new(0,10,1,-44),302)
local BtnIYCancel=makeBtn(IYWindow,T("del_cancel"),UDim2.new(0,120,0,34),UDim2.new(1,-130,1,-44),302)
BtnIYCancel.MouseButton1Click:Connect(function() IYWindow.Visible=false end)
BtnIYRun.MouseButton1Click:Connect(function()
    IYWindow.Visible=false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",true))()
end)
_G.DH.IYWindow=IYWindow

-- ======= JANELA CONFIG =======
local CfgWindow=makeFrame(SGui,UDim2.new(0,280,0,220),UDim2.new(0.5,-140,0.5,-110),
    Color3.fromRGB(13,13,18),300)
CfgWindow.Visible=false
local CfgTBar,_=makeFrame(CfgWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
local CfgTLbl=makeLbl(CfgTBar,T("cfg_title"),UDim2.new(1,-40,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local BtnCfgClose=makeBtn(CfgTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),302)
BtnCfgClose.MouseButton1Click:Connect(function() CfgWindow.Visible=false end)
local CfgLangLbl=makeLbl(CfgWindow,T("cfg_lang"),UDim2.new(1,-20,0,18),UDim2.new(0,10,0,46),301,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
local BtnCfgLang=makeBtn(CfgWindow,"🌍 "..(_G.DH.lang or "pt_BR"),UDim2.new(1,-20,0,34),UDim2.new(0,10,0,66),302)
BtnCfgLang.TextSize=12
BtnCfgLang.MouseButton1Click:Connect(function()
    CfgWindow.Visible=false; LangWindow.Visible=true
end)
local CfgBorderLbl=makeLbl(CfgWindow,T("cfg_border"),UDim2.new(1,-20,0,18),UDim2.new(0,10,0,110),301,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
local BtnCfgPalette=makeBtn(CfgWindow,"🎨 Paleta de Cores",UDim2.new(1,-20,0,34),UDim2.new(0,10,0,130),302)
BtnCfgPalette.TextSize=12
BtnCfgPalette.MouseButton1Click:Connect(function()
    CfgWindow.Visible=false; PaletteWindow.Visible=true
end)
_G.DH.CfgWindow=CfgWindow

-- ======= JANELA EDITOR =======
local EditorWindow=makeFrame(SGui,UDim2.new(0,380,0,460),UDim2.new(0.5,-190,0.5,-230),
    Color3.fromRGB(13,13,18),300)
EditorWindow.Visible=false
local EdTBar,_=makeFrame(EditorWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
local EdTLbl=makeLbl(EdTBar,T("editor_title"),UDim2.new(1,-40,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local BtnEdClose=makeBtn(EdTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),302)
BtnEdClose.MouseButton1Click:Connect(function() EditorWindow.Visible=false end)
makeLbl(EditorWindow,T("editor_name"),UDim2.new(1,-20,0,16),UDim2.new(0,10,0,44),301,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
local EdNameBox=Instance.new("TextBox")
EdNameBox.Size=UDim2.new(1,-20,0,32);EdNameBox.Position=UDim2.new(0,10,0,62)
EdNameBox.BackgroundColor3=Color3.fromRGB(22,22,30);EdNameBox.BorderSizePixel=0
EdNameBox.PlaceholderText=T("editor_nameph");EdNameBox.TextColor3=Color3.fromRGB(240,240,245)
EdNameBox.PlaceholderColor3=Color3.fromRGB(100,100,120);EdNameBox.Font=Enum.Font.Gotham
EdNameBox.TextSize=13;EdNameBox.ZIndex=301;EdNameBox.ClearTextOnFocus=false;EdNameBox.Text=""
EdNameBox.Parent=EditorWindow
Instance.new("UIPadding",EdNameBox).PaddingLeft=UDim.new(0,10)
makeLbl(EditorWindow,T("editor_code"),UDim2.new(1,-20,0,16),UDim2.new(0,10,0,102),301,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
local EdCodeBox=Instance.new("TextBox")
EdCodeBox.Size=UDim2.new(1,-20,0,240);EdCodeBox.Position=UDim2.new(0,10,0,120)
EdCodeBox.BackgroundColor3=Color3.fromRGB(12,18,12);EdCodeBox.BorderSizePixel=0
EdCodeBox.PlaceholderText="-- Escreva seu script aqui...";EdCodeBox.TextColor3=Color3.fromRGB(0,230,120)
EdCodeBox.PlaceholderColor3=Color3.fromRGB(60,100,60);EdCodeBox.Font=Enum.Font.Code
EdCodeBox.TextSize=11;EdCodeBox.MultiLine=true;EdCodeBox.TextXAlignment=Enum.TextXAlignment.Left
EdCodeBox.TextYAlignment=Enum.TextYAlignment.Top
EdCodeBox.ZIndex=301;EdCodeBox.ClearTextOnFocus=false;EdCodeBox.Text=""
EdCodeBox.Parent=EditorWindow
local ecp=Instance.new("UIPadding",EdCodeBox);ecp.PaddingLeft=UDim.new(0,8);ecp.PaddingTop=UDim.new(0,6)
local BtnEdSave=makeBtn(EditorWindow,T("editor_save"),UDim2.new(0,100,0,34),UDim2.new(0,10,1,-44),302)
local BtnEdRun=makeBtn(EditorWindow,T("editor_run"),UDim2.new(0,100,0,34),UDim2.new(0.5,-50,1,-44),302)
local BtnEdCancel2=makeBtn(EditorWindow,T("editor_cancel"),UDim2.new(0,100,0,34),UDim2.new(1,-110,1,-44),302)
BtnEdCancel2.MouseButton1Click:Connect(function() EditorWindow.Visible=false end)

local edEditingName=""
local function openEditor(name, code)
    edEditingName=name or ""
    EdNameBox.Text=name or ""
    EdCodeBox.Text=code or ""
    EdTLbl.Text=name~="" and T("editor_title").." - "..name or T("editor_new")
    EditorWindow.Visible=true
end
BtnEdSave.MouseButton1Click:Connect(function()
    local n=EdNameBox.Text; local c=EdCodeBox.Text
    if n=="" then notify("⚠️ Nome vazio!",255,190,0) return end
    if edEditingName~="" and edEditingName~=n then
        _G.DH.deleteScript(edEditingName) end
    _G.DH.saveScript(n,c)
    notify("💾 Salvo: "..n,0,180,80)
    EditorWindow.Visible=false
    if _G.DH.refreshScripts then _G.DH.refreshScripts() end
end)
BtnEdRun.MouseButton1Click:Connect(function()
    local ok,err=pcall(function()
        local fn=loadstring(EdCodeBox.Text); if fn then fn() end
    end)
    notify(ok and T("exec_ok") or T("exec_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
end)
_G.DH.EditorWindow=EditorWindow
_G.DH.openEditor=openEditor

-- ======= JANELA DELETAR =======
local DelWindow=makeFrame(SGui,UDim2.new(0,280,0,150),UDim2.new(0.5,-140,0.5,-75),
    Color3.fromRGB(13,13,18),300)
DelWindow.Visible=false
local DelTBar,_=makeFrame(DelWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
local DelTLbl=makeLbl(DelTBar,T("del_title"),UDim2.new(1,-20,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local DelMsgLbl=makeLbl(DelWindow,"",UDim2.new(1,-20,0,30),UDim2.new(0,10,0,44),301,nil,Color3.fromRGB(200,180,200),12)
local BtnDelOk=makeBtn(DelWindow,T("del_confirm"),UDim2.new(0,110,0,34),UDim2.new(0,10,1,-44),302)
BtnDelOk.BackgroundColor3=Color3.fromRGB(80,20,20)
local BtnDelCancel=makeBtn(DelWindow,T("del_cancel"),UDim2.new(0,110,0,34),UDim2.new(1,-120,1,-44),302)
BtnDelCancel.MouseButton1Click:Connect(function() DelWindow.Visible=false end)
local delTarget=""
local function openDelWindow(name)
    delTarget=name; DelMsgLbl.Text=T("del_msg")..'"'..name..'"?'
    DelTLbl.Text=T("del_title"); BtnDelOk.Text=T("del_confirm"); BtnDelCancel.Text=T("del_cancel")
    DelWindow.Visible=true
end
BtnDelOk.MouseButton1Click:Connect(function()
    _G.DH.deleteScript(delTarget); DelWindow.Visible=false
    notify("🗑 Deletado: "..delTarget,220,50,50)
    if _G.DH.refreshScripts then _G.DH.refreshScripts() end
end)
_G.DH.DelWindow=DelWindow
_G.DH.openDelWindow=openDelWindow

-- ======= JANELA PESQUISA =======
local SearchWindow=makeFrame(SGui,UDim2.new(0,300,0,300),UDim2.new(0.5,-150,0.5,-150),
    Color3.fromRGB(13,13,18),300)
SearchWindow.Visible=false
local SrchTBar,_=makeFrame(SearchWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,28),301)
makeLbl(SrchTBar,"🔍 Pesquisar",UDim2.new(1,-40,1,0),UDim2.new(0,10,0,0),302,Enum.TextXAlignment.Left,nil,13)
local BtnSrchClose=makeBtn(SrchTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),302)
BtnSrchClose.MouseButton1Click:Connect(function() SearchWindow.Visible=false end)
local SrchBox=Instance.new("TextBox")
SrchBox.Size=UDim2.new(1,-20,0,34);SrchBox.Position=UDim2.new(0,10,0,44)
SrchBox.BackgroundColor3=Color3.fromRGB(22,22,30);SrchBox.BorderSizePixel=0
SrchBox.PlaceholderText=T("search_ph");SrchBox.TextColor3=Color3.fromRGB(240,240,245)
SrchBox.PlaceholderColor3=Color3.fromRGB(100,100,120);SrchBox.Font=Enum.Font.Gotham
SrchBox.TextSize=13;SrchBox.ZIndex=301;SrchBox.ClearTextOnFocus=false;SrchBox.Text=""
SrchBox.Parent=SearchWindow
Instance.new("UIPadding",SrchBox).PaddingLeft=UDim.new(0,10)
local SrchScroll=makeScroll(SearchWindow,UDim2.new(1,-8,1,-90),UDim2.new(0,4,0,84),301)
local function doSearch(query)
    for _,c in pairs(SrchScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    if query=="" then return end
    local scripts=_G.DH.getAllScripts()
    for _,s in ipairs(scripts) do
        if s.name:lower():find(query:lower(),1,true) then
            local rb=makeBtn(SrchScroll,s.name,UDim2.new(1,0,0,36),nil,302)
            rb.TextSize=12
            rb.MouseButton1Click:Connect(function()
                SearchWindow.Visible=false
                _G.DH.openEditor(s.name,s.code)
            end)
        end
    end
end
SrchBox:GetPropertyChangedSignal("Text"):Connect(function() doSearch(SrchBox.Text) end)
_G.DH.SearchWindow=SearchWindow

-- ======= JANELA ADMIN (BAN) =======
local AdminWindow=makeFrame(SGui,UDim2.new(0,320,0,260),UDim2.new(0.5,-160,0.5,-130),
    Color3.fromRGB(13,13,18),500)
AdminWindow.Visible=false
local AdminTBar,_=makeFrame(AdminWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(40,10,10),501)
makeLbl(AdminTBar,"🛡 Painel Admin",UDim2.new(1,-40,1,0),UDim2.new(0,10,0,0),502,Enum.TextXAlignment.Left,Color3.fromRGB(255,100,100),13)
local BtnAdminClose=makeBtn(AdminTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),502)
BtnAdminClose.MouseButton1Click:Connect(function() AdminWindow.Visible=false end)
local AdminScriptLbl=makeLbl(AdminWindow,"",UDim2.new(1,-20,0,18),UDim2.new(0,10,0,44),501,Enum.TextXAlignment.Left,Color3.fromRGB(220,200,200),12)
local AdminAuthLbl=makeLbl(AdminWindow,"",UDim2.new(1,-20,0,14),UDim2.new(0,10,0,64),501,Enum.TextXAlignment.Left,Color3.fromRGB(180,140,140),11)
makeLbl(AdminWindow,"🔑 Senha admin:",UDim2.new(1,-20,0,16),UDim2.new(0,10,0,88),501,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
local AdminPwBox=Instance.new("TextBox")
AdminPwBox.Size=UDim2.new(1,-20,0,32);AdminPwBox.Position=UDim2.new(0,10,0,106)
AdminPwBox.BackgroundColor3=Color3.fromRGB(30,15,15);AdminPwBox.BorderSizePixel=0
AdminPwBox.PlaceholderText="Digite a senha...";AdminPwBox.TextColor3=Color3.fromRGB(255,180,180)
AdminPwBox.PlaceholderColor3=Color3.fromRGB(100,80,80);AdminPwBox.Font=Enum.Font.Code
AdminPwBox.TextSize=12;AdminPwBox.ZIndex=501;AdminPwBox.ClearTextOnFocus=false;AdminPwBox.Text=""
AdminPwBox.Parent=AdminWindow
Instance.new("UIPadding",AdminPwBox).PaddingLeft=UDim.new(0,10)
local BtnAdminDel=makeBtn(AdminWindow,"🗑 Deletar Script",UDim2.new(0,140,0,32),UDim2.new(0,10,0,148),502)
BtnAdminDel.BackgroundColor3=Color3.fromRGB(80,20,20);BtnAdminDel.TextSize=11
local BtnAdminBan=makeBtn(AdminWindow,"🚫 Banir Usuário",UDim2.new(0,140,0,32),UDim2.new(1,-150,0,148),502)
BtnAdminBan.BackgroundColor3=Color3.fromRGB(60,20,60);BtnAdminBan.TextSize=11
local BtnAdminDelBan=makeBtn(AdminWindow,"💀 Deletar + Banir",UDim2.new(1,-20,0,32),UDim2.new(0,10,0,188),502)
BtnAdminDelBan.BackgroundColor3=Color3.fromRGB(80,10,10);BtnAdminDelBan.TextSize=11

_G.DH.AdminWindow=AdminWindow
_G.DH.AdminPwBox=AdminPwBox
_G.DH.BtnAdminDel=BtnAdminDel
_G.DH.BtnAdminBan=BtnAdminBan
_G.DH.BtnAdminDelBan=BtnAdminDelBan
_G.DH.AdminScriptLbl=AdminScriptLbl
_G.DH.AdminAuthLbl=AdminAuthLbl
