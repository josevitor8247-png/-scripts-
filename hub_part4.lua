-- DeltaHub PARTE 4: Hub Principal + Comunidade + Votação + Ban
local T         = _G.DH.T
local makeFrame = _G.DH.makeFrame
local makeLbl   = _G.DH.makeLbl
local makeBtn   = _G.DH.makeBtn
local makeScroll= _G.DH.makeScroll
local notify    = _G.DH.notify
local player    = _G.DH.player
local SGui      = _G.DH.ScreenGui

local GH_TOKEN = "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"
local GH_USER  = "josevitor8247-png"
local GH_REPO  = "-scripts-"
local RAW_BASE = "https://raw.githubusercontent.com/"..GH_USER.."/"..GH_REPO.."/main/"
local API_BASE = "https://api.github.com/repos/"..GH_USER.."/"..GH_REPO.."/contents/"

local _p1,_p2,_p3 = "AHFI2TF929","56929DUJWS","HJOWF"
local BAN_PW = _p1.._p2.._p3
local BAN_FILE = "DeltaHub/admin/banlist.dat"
if not isfolder("DeltaHub/admin/") then makefolder("DeltaHub/admin/") end
if not isfile(BAN_FILE) then writefile(BAN_FILE,"##"..BAN_PW.."##\n") end

local ADMIN_NAMES = {"noob_artl2","noob_arl2"}
local MY_NAME = player.Name
local function isAdmin()
    local n=MY_NAME:lower()
    for _,a in ipairs(ADMIN_NAMES) do if n==a then return true end end
    return false
end

local function verifyBanFile()
    if not isfile(BAN_FILE) then return false end
    return readfile(BAN_FILE):sub(1,#BAN_PW+4)=="##"..BAN_PW.."##"
end
local function getBannedList()
    if not verifyBanFile() then return {} end
    local banned={}
    for line in readfile(BAN_FILE):gmatch("[^\n]+") do
        local id=line:match("^%[([^%]]+)%]")
        if id then banned[id:lower()]=true end
    end
    return banned
end
local function isBanned(username)
    return getBannedList()[username:lower()]==true
end
local function banUser(username, pw)
    if pw~=BAN_PW then return false,"senha_errada" end
    if not verifyBanFile() then writefile(BAN_FILE,"##"..BAN_PW.."##\n") end
    if isBanned(username) then return false,"ja_banido" end
    writefile(BAN_FILE, readfile(BAN_FILE).."["..username:lower().."]\n")
    return true
end

-- HTTP
local reqFunc=nil
task.spawn(function()
    for _,f in ipairs({
        function() return request end,
        function() return syn and syn.request end,
        function() return http and http.request end,
        function() return http_request end,
        function() return getgenv and getgenv().request end,
    }) do
        local ok,r=pcall(f)
        if ok and type(r)=="function" then reqFunc=r; break end
    end
end)

local function b64e(data)
    local b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local r=""; local bytes={tostring(data):byte(1,-1)}
    for i=1,#bytes,3 do
        local b1,b2,b3=bytes[i],bytes[i+1] or 0,bytes[i+2] or 0
        local n=b1*65536+b2*256+b3
        r=r..b:sub(math.floor(n/262144)%64+1,math.floor(n/262144)%64+1)
             ..b:sub(math.floor(n/4096)%64+1,math.floor(n/4096)%64+1)
             ..b:sub(math.floor(n/64)%64+1,math.floor(n/64)%64+1)
             ..b:sub(n%64+1,n%64+1)
    end
    if #bytes%3==1 then r=r:sub(1,-3).."=="
    elseif #bytes%3==2 then r=r:sub(1,-2).."=" end
    return r
end
local function jEsc(s)
    s=tostring(s)
    return s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n"):gsub("\r",""):gsub("\t","  ")
end
local function ghRaw(file)
    local ok,r=pcall(function()
        return game:HttpGet(RAW_BASE..file.."?t="..os.time(),true)
    end)
    return ok and r or nil
end
local function ghSHA(file)
    local ok,r=pcall(function() return game:HttpGet(API_BASE..file,true) end)
    if not ok then return nil end
    return r:match('"sha":"([^"]+)"')
end
local function ghWrite(file,content)
    if not reqFunc then
        notify("❌ HTTP não disponível",220,50,50)
        return false
    end
    local sha=ghSHA(file)
    local body='{"message":"update","content":"'..b64e(content)..'"'
    if sha then body=body..',"sha":"'..sha..'"' end
    body=body.."}"
    local ok,res=pcall(reqFunc,{
        Url=API_BASE..file, Method="PUT",
        Headers={
            ["Authorization"]="token "..GH_TOKEN,
            ["Content-Type"]="application/json",
            ["Accept"]="application/vnd.github.v3+json",
        },
        Body=body,
    })
    if not ok or not res then return false end
    local status=res.StatusCode or res.status or 0
    return status>=200 and status<300
end
local function isJunk(name,code)
    if #name<2 or #code<10 then return true end
    local kw={"function","local","game","print","loadstring","script","end","if ","for ","while ","return"}
    for _,k in ipairs(kw) do if code:lower():find(k,1,true) then return false end end
    return true
end

-- ======= HUB PRINCIPAL =======
local WINDOW_W,WINDOW_H=350,440
local Main=makeFrame(SGui, UDim2.new(0,WINDOW_W,0,WINDOW_H),
    UDim2.new(0.5,-WINDOW_W/2,0.5,-WINDOW_H/2),
    Color3.fromRGB(13,13,18), 2)
Main.Visible=false

local MainStroke=Main:FindFirstChildOfClass("UIStroke")
if MainStroke then MainStroke.Thickness=2.5 end
_G.DH.border=MainStroke

-- Titlebar
local TitleBar,_=makeFrame(Main,UDim2.new(1,0,0,40),UDim2.new(0,0,0,0),Color3.fromRGB(18,18,28),3)
TitleBar.ZIndex=3
local TitleLbl=makeLbl(TitleBar,T("title"),UDim2.new(0,110,1,0),UDim2.new(0,10,0,0),4,Enum.TextXAlignment.Left,nil,14)
local BetaLbl=makeLbl(TitleBar,"beta",UDim2.new(0,40,0,16),UDim2.new(0,122,0,7),4,nil,Color3.fromRGB(110,60,255),9)
_G.DH.betaRGB=BetaLbl

-- Content area
local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,0,1,-40);Content.Position=UDim2.new(0,0,0,40)
Content.BackgroundTransparency=1;Content.ZIndex=3;Content.Parent=Main

-- ======= BOTÕES TITLEBAR =======
local function makeTBtn(txt,x)
    local b=makeBtn(TitleBar,txt,UDim2.new(0,28,0,28),UDim2.new(1,x,0.5,-14),4)
    b.TextSize=12;return b
end
local BtnClose    =makeTBtn("✕",-30)
local BtnMinimize =makeTBtn("─",-62)
local BtnCfg      =makeTBtn("⚙️",-98)
local BtnSearch   =makeTBtn("🔍",-130)
local BtnGames    =makeTBtn("🎮",-162)
local BtnCommunity=makeTBtn("🌐",-194)
local BtnVote     =makeTBtn("👥",-226)
local BtnNew      =makeTBtn("＋",-258)

-- Arrastar
do
    local dragging,dragStart,startPos=false,nil,nil
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=Main.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or
           i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- ======= VIEWS =======

-- VIEW: Scripts locais
local ScriptsView=Instance.new("Frame")
ScriptsView.Size=UDim2.new(1,0,1,0);ScriptsView.BackgroundTransparency=1
ScriptsView.ZIndex=3;ScriptsView.Parent=Content
local ScriptsScroll=makeScroll(ScriptsView,UDim2.new(1,-14,1,-8),UDim2.new(0,7,0,4),3)
local EmptyLbl=makeLbl(ScriptsView,T("no_scripts"),UDim2.new(1,0,0,40),UDim2.new(0,0,0.4,0),3,
    nil,Color3.fromRGB(100,100,130),12)

local function refreshScripts()
    for _,c in pairs(ScriptsScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local scripts=_G.DH.getAllScripts()
    EmptyLbl.Visible=#scripts==0
    for _,s in ipairs(scripts) do
        local card,_=makeFrame(ScriptsScroll,UDim2.new(1,0,0,54),nil,Color3.fromRGB(18,18,28),4)
        local sn=s
        makeLbl(card,"📄 "..s.name,UDim2.new(1,-150,0,28),UDim2.new(0,10,0,5),5,Enum.TextXAlignment.Left,nil,12)
        local BRun=makeBtn(card,T("btn_run"),  UDim2.new(0,42,0,28),UDim2.new(1,-170,0.5,-14),5)
        local BEd =makeBtn(card,T("btn_edit"), UDim2.new(0,42,0,28),UDim2.new(1,-122,0.5,-14),5)
        local BCp =makeBtn(card,T("btn_copy"), UDim2.new(0,42,0,28),UDim2.new(1,-74,0.5,-14), 5)
        local BDel=makeBtn(card,T("btn_delete"),UDim2.new(0,42,0,28),UDim2.new(1,-26,0.5,-14),5)
        BRun.TextSize=9;BEd.TextSize=9;BCp.TextSize=9;BDel.TextSize=9
        BDel.BackgroundColor3=Color3.fromRGB(60,15,15)
        BRun.MouseButton1Click:Connect(function()
            local ok,err=pcall(function() local fn=loadstring(sn.code); if fn then fn() end end)
            notify(ok and T("exec_ok") or T("exec_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
        end)
        BEd.MouseButton1Click:Connect(function() _G.DH.openEditor(sn.name,sn.code) end)
        BCp.MouseButton1Click:Connect(function()
            pcall(function() game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage",{Text=sn.code}) end)
            notify("⧉ Copiado!",0,160,255)
        end)
        BDel.MouseButton1Click:Connect(function() _G.DH.openDelWindow(sn.name) end)
    end
end
_G.DH.refreshScripts=refreshScripts

-- VIEW: Jogos
local GamesView=Instance.new("Frame")
GamesView.Size=UDim2.new(1,0,1,0);GamesView.BackgroundTransparency=1
GamesView.ZIndex=3;GamesView.Visible=false;GamesView.Parent=Content
local GamesScroll=makeScroll(GamesView,UDim2.new(1,-14,1,-50),UDim2.new(0,7,0,4),3)
local GamesTitleLbl=makeLbl(GamesView,T("games_title"),UDim2.new(1,0,0,26),UDim2.new(0,8,0,4),4,Enum.TextXAlignment.Left,nil,14)

-- Card IY
local IYCard,IYStroke=makeFrame(GamesScroll,UDim2.new(1,0,0,78),nil,Color3.fromRGB(22,22,32),4)
IYStroke.Thickness=3;_G.DH.IYStroke=IYStroke
local IYTag=makeLbl(IYCard,T("game_iy_tag"),UDim2.new(0,90,0,20),UDim2.new(0,8,0,4),5,nil,Color3.fromRGB(255,220,0),10)
makeLbl(IYCard,T("game_iy"),UDim2.new(1,-120,0,20),UDim2.new(0,8,0,26),5,Enum.TextXAlignment.Left,nil,12)
makeLbl(IYCard,T("game_iy_script"),UDim2.new(1,-120,0,16),UDim2.new(0,8,0,48),5,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),10)
local BtnIY=makeBtn(IYCard,T("game_run"),UDim2.new(0,55,0,36),UDim2.new(1,-62,0.5,-18),5)
BtnIY.TextSize=11
BtnIY.MouseButton1Click:Connect(function() _G.DH.IYWindow.Visible=true end)

-- Separador
local Sep=Instance.new("Frame",GamesScroll)
Sep.Size=UDim2.new(1,0,0,2);Sep.BackgroundColor3=Color3.fromRGB(40,35,60);Sep.BorderSizePixel=0

-- Card MM2
local MM2Card,_=makeFrame(GamesScroll,UDim2.new(1,0,0,68),nil,Color3.fromRGB(22,22,32),4)
makeLbl(MM2Card,"📍 "..T("game_mm2"),UDim2.new(1,-120,0,20),UDim2.new(0,8,0,6),5,Enum.TextXAlignment.Left,nil,12)
makeLbl(MM2Card,T("game_yarhm"),UDim2.new(1,-120,0,16),UDim2.new(0,8,0,28),5,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),10)
local BtnMM2=makeBtn(MM2Card,T("game_run"),UDim2.new(0,55,0,36),UDim2.new(1,-62,0.5,-18),5)
BtnMM2.TextSize=11
BtnMM2.MouseButton1Click:Connect(function() _G.DH.YARHMWindow.Visible=true end)

local BtnGamesBack=makeBtn(GamesView,T("games_back"),UDim2.new(1,-16,0,34),UDim2.new(0,8,1,-38),4)

-- VIEW: Comunidade (montada na Parte 4)
local CommunityView=Instance.new("Frame")
CommunityView.Size=UDim2.new(1,0,1,0);CommunityView.BackgroundTransparency=1
CommunityView.ZIndex=3;CommunityView.Visible=false;CommunityView.Parent=Content
local CommTitleLbl=makeLbl(CommunityView,T("community_title"),UDim2.new(1,-120,0,30),UDim2.new(0,0,0,5),4,Enum.TextXAlignment.Left,nil,15)
local BtnNewPublic=makeBtn(CommunityView,T("community_new"),UDim2.new(0,112,0,28),UDim2.new(1,-116,0,8),4)
BtnNewPublic.TextSize=10
local CommScroll=makeScroll(CommunityView,UDim2.new(1,-14,1,-48),UDim2.new(0,7,0,42),3)
local CommEmptyLbl=makeLbl(CommunityView,T("community_loading"),UDim2.new(1,0,0,50),UDim2.new(0,0,0.4,0),3,nil,Color3.fromRGB(140,140,165),13)

-- VIEW: Votação
local VoteView=Instance.new("Frame")
VoteView.Size=UDim2.new(1,0,1,0);VoteView.BackgroundTransparency=1
VoteView.ZIndex=3;VoteView.Visible=false;VoteView.Parent=Content
local VoteTitleLbl=makeLbl(VoteView,T("vote_title"),UDim2.new(1,-16,0,30),UDim2.new(0,8,0,5),4,Enum.TextXAlignment.Left,nil,15)
local VoteScroll=makeScroll(VoteView,UDim2.new(1,-14,1,-48),UDim2.new(0,7,0,42),3)
local VoteEmptyLbl=makeLbl(VoteView,T("vote_loading"),UDim2.new(1,0,0,50),UDim2.new(0,0,0.4,0),3,nil,Color3.fromRGB(140,140,165),13)
-- Botão admin para adicionar nova votação
local BtnVoteAdd=nil
if isAdmin() then
    BtnVoteAdd=makeBtn(VoteView,"＋ Adicionar",UDim2.new(0,90,0,28),UDim2.new(1,-94,0,8),4)
    BtnVoteAdd.TextSize=10
end

-- ======= TOGGLES DE VIEW =======
local gamesMode=false
local communityMode=false
local voteMode=false

local function showView(view)
    ScriptsView.Visible=false; GamesView.Visible=false
    CommunityView.Visible=false; VoteView.Visible=false
    BtnNew.Visible=false; gamesMode=false; communityMode=false; voteMode=false
    view.Visible=true
end
local function showScripts()
    showView(ScriptsView); BtnNew.Visible=true
    refreshScripts()
end
local function showGames()
    showView(GamesView); gamesMode=true
    BtnMM2.Text=T("game_run"); BtnGamesBack.Text=T("games_back")
    IYTag.Text=T("game_iy_tag"); BtnIY.Text=T("game_run")
end

BtnGamesBack.MouseButton1Click:Connect(showScripts)
BtnGames.MouseButton1Click:Connect(function()
    if gamesMode then showScripts() else showGames() end
end)
BtnNew.MouseButton1Click:Connect(function()
    EdNameBox=""
    _G.DH.openEditor("","")
end)

-- ======= COMUNIDADE: LOAD =======
local communityScripts={}
local function loadCommunityScripts()
    CommEmptyLbl.Text=T("community_loading"); CommEmptyLbl.Visible=true
    task.spawn(function()
        local raw=ghRaw("scripts.json")
        communityScripts={}
        if raw then
            for entry in raw:gmatch('\{([^{}]+)\}') do
                local id    =entry:match('"id":"([^"]*)"')
                local name  =entry:match('"name":"([^"]*)"')
                local author=entry:match('"author":"([^"]*)"')
                local code  =entry:match('"code":"([^"]*)"')
                local gameId=entry:match('"gameId":"([^"]*)"') or ""
                local tags  =entry:match('"tags":"([^"]*)"') or ""
                local stars =tonumber(entry:match('"stars":([%d%.]+)')) or 0
                local likes =tonumber(entry:match('"likes":(%d+)')) or 0
                local cmts  =tonumber(entry:match('"comments":(%d+)')) or 0
                local week  =entry:match('"week":"([^"]*)"') or ""
                if id and name and author and code then
                    code=code:gsub("\\n","\n"):gsub('\\"','"')
                    table.insert(communityScripts,{id=id,name=name,author=author,
                        code=code,gameId=gameId,tags=tags,stars=stars,likes=likes,
                        comments=cmts,week=week})
                end
            end
        end
        for _,c in pairs(CommScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        CommEmptyLbl.Visible=#communityScripts==0
        if #communityScripts==0 then CommEmptyLbl.Text=T("community_empty") end
        local weekStr=os.date and os.date("%Y-W%V") or ""
        local banned=getBannedList()
        for _,s in ipairs(communityScripts) do
            local isTop=(s.stars>=4 or s.comments>=5) and s.week==weekStr
            local Card,CS=makeFrame(CommScroll,UDim2.new(1,0,0,70),nil,Color3.fromRGB(22,22,30),4)
            if isTop then CS.Thickness=3 end; CS.Transparency=isTop and 0 or 0.4
            local Strip=Instance.new("Frame"); Strip.Size=UDim2.new(0,4,0.7,0)
            Strip.Position=UDim2.new(0,6,0.15,0); Strip.BackgroundColor3=Color3.fromRGB(110,60,255)
            Strip.BorderSizePixel=0; Strip.ZIndex=5; Strip.Parent=Card
            makeLbl(Card,"📄 "..s.name,UDim2.new(1,-185,0,20),UDim2.new(0,18,0,5),5,Enum.TextXAlignment.Left,nil,12)
            local ac=banned[s.author:lower()] and Color3.fromRGB(255,80,80) or Color3.fromRGB(140,140,165)
            makeLbl(Card,"👤 "..s.author..(banned[s.author:lower()] and " 🚫" or ""),UDim2.new(1,-185,0,14),UDim2.new(0,18,0,26),5,Enum.TextXAlignment.Left,ac,10)
            makeLbl(Card,"⭐"..string.format("%.1f",s.stars).." 💬"..s.comments..(s.gameId~="" and " 🎮" or ""),UDim2.new(1,-185,0,14),UDim2.new(0,18,0,44),5,Enum.TextXAlignment.Left,Color3.fromRGB(180,160,255),10)
            local BRC=makeBtn(Card,T("btn_exec"),   UDim2.new(0,32,0,26),UDim2.new(1,-174,0.5,-13),5)
            local BCC=makeBtn(Card,T("btn_comment"),UDim2.new(0,32,0,26),UDim2.new(1,-136,0.5,-13),5)
            local BSC=makeBtn(Card,T("btn_stars"),  UDim2.new(0,32,0,26),UDim2.new(1,-98,0.5,-13), 5)
            local BDC=makeBtn(Card,T("btn_report"), UDim2.new(0,32,0,26),UDim2.new(1,-60,0.5,-13), 5)
            BRC.TextSize=10;BCC.TextSize=10;BSC.TextSize=10;BDC.TextSize=10
            if isAdmin() then
                local BAdm=makeBtn(Card,"🗑",UDim2.new(0,26,0,26),UDim2.new(1,-208,0.5,-13),5)
                BAdm.TextSize=10;BAdm.BackgroundColor3=Color3.fromRGB(80,20,20)
                local sc=s
                BAdm.MouseButton1Click:Connect(function()
                    _G.DH.AdminScriptLbl.Text="📄 "..sc.name
                    _G.DH.AdminAuthLbl.Text="👤 "..sc.author
                    _G.DH.AdminPwBox.Text=""; _G.DH.AdminWindow.Visible=true
                    _G.DH.adminTarget=sc
                end)
            end
            local sc=s
            BRC.MouseButton1Click:Connect(function()
                if isBanned(sc.author) then notify("🚫 Usuário banido!",220,50,50) return end
                ExecWindow.Visible=true; curExec=sc
                ExecTitleLbl.Text=T("exec_title"); ExecDescLbl.Text="📄 "..sc.name
                ExecAuthLbl.Text="👤 "..sc.author
            end)
            BCC.MouseButton1Click:Connect(function() openCommentWindow(sc) end)
            BSC.MouseButton1Click:Connect(function()
                curStars=sc; StarsWindow.Visible=true
                StarsDescLbl.Text="📄 "..sc.name; selStars=0
                for _,b in ipairs(starBtns) do b.BackgroundColor3=Color3.fromRGB(20,20,30) end
            end)
            BDC.MouseButton1Click:Connect(function()
                curReport=sc; ReportWindow.Visible=true
                ReportDescLbl.Text='Denunciar "'..sc.name..'"?'
            end)
        end
    end)
end

-- ======= JANELAS COMUNIDADE =======

-- Exec
local ExecWindow,_=makeFrame(SGui,UDim2.new(0,300,0,160),UDim2.new(0.5,-150,0.5,-80),Color3.fromRGB(13,13,18),400)
ExecWindow.Visible=false
local ExecTBar,_=makeFrame(ExecWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,30),401)
local ExecTitleLbl=makeLbl(ExecTBar,T("exec_title"),UDim2.new(1,-20,1,0),UDim2.new(0,12,0,0),402,Enum.TextXAlignment.Left,nil,14)
local ExecDescLbl=makeLbl(ExecWindow,"",UDim2.new(1,-20,0,22),UDim2.new(0,10,0,44),401,Enum.TextXAlignment.Left,Color3.fromRGB(180,180,200),12)
local ExecAuthLbl=makeLbl(ExecWindow,"",UDim2.new(1,-20,0,16),UDim2.new(0,10,0,68),401,Enum.TextXAlignment.Left,Color3.fromRGB(120,120,150),10)
local BtnExecRun=makeBtn(ExecWindow,T("exec_confirm"),UDim2.new(0,120,0,34),UDim2.new(0,10,1,-44),402)
local BtnExecCancel=makeBtn(ExecWindow,T("exec_cancel"),UDim2.new(0,120,0,34),UDim2.new(1,-130,1,-44),402)
local curExec=nil
BtnExecCancel.MouseButton1Click:Connect(function() ExecWindow.Visible=false end)
BtnExecRun.MouseButton1Click:Connect(function()
    if not curExec then return end; ExecWindow.Visible=false
    local ok,err=pcall(function() local fn=loadstring(curExec.code); if fn then fn() end end)
    notify(ok and T("exec_ok") or T("exec_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
end)

-- Comentários
local CommWindow,_=makeFrame(SGui,UDim2.new(0,320,0,380),UDim2.new(0.5,-160,0.5,-190),Color3.fromRGB(13,13,18),400)
CommWindow.Visible=false
local CommWTBar,_=makeFrame(CommWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,30),401)
local CommWTitle=makeLbl(CommWTBar,T("comment_title"),UDim2.new(1,-40,1,0),UDim2.new(0,12,0,0),402,Enum.TextXAlignment.Left)
local BtnCommClose=makeBtn(CommWTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),402)
BtnCommClose.MouseButton1Click:Connect(function() CommWindow.Visible=false end)
local CommListScroll=makeScroll(CommWindow,UDim2.new(1,-12,1,-100),UDim2.new(0,6,0,44),401)
local CommBox=Instance.new("TextBox")
CommBox.Size=UDim2.new(1,-90,0,34);CommBox.Position=UDim2.new(0,8,1,-44)
CommBox.BackgroundColor3=Color3.fromRGB(22,22,30);CommBox.BorderSizePixel=0
CommBox.PlaceholderText=T("comment_ph");CommBox.TextColor3=Color3.fromRGB(240,240,245)
CommBox.PlaceholderColor3=Color3.fromRGB(100,100,120);CommBox.Font=Enum.Font.Gotham
CommBox.TextSize=12;CommBox.ZIndex=401;CommBox.ClearTextOnFocus=false;CommBox.Text=""
CommBox.Parent=CommWindow; Instance.new("UIPadding",CommBox).PaddingLeft=UDim.new(0,8)
local BtnCommSend=makeBtn(CommWindow,T("comment_send"),UDim2.new(0,74,0,34),UDim2.new(1,-82,1,-44),402)
BtnCommSend.TextSize=11
local curComm=nil
local function openCommentWindow(sc)
    curComm=sc; CommWTitle.Text=T("comment_title").." - "..sc.name; CommBox.Text=""
    for _,c in pairs(CommListScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    CommWindow.Visible=true
    task.spawn(function()
        local raw=ghRaw("scripts.json"); if not raw then return end
        for entry in raw:gmatch('\{([^{}]+)\}') do
            if entry:find('"id":"'..sc.id..'"') then
                for a,t in (entry:match('"comments_list":%[(.-)%]') or ""):gmatch('"author":"([^"]+)","text":"([^"]+)"') do
                    local CF,_=makeFrame(CommListScroll,UDim2.new(1,0,0,50),nil,Color3.fromRGB(22,22,30),402)
                    makeLbl(CF,"👤 "..a,UDim2.new(1,-10,0,16),UDim2.new(0,8,0,4),403,Enum.TextXAlignment.Left,Color3.fromRGB(180,160,255),10)
                    local tl=makeLbl(CF,t:gsub("\\n","\n"),UDim2.new(1,-10,0,26),UDim2.new(0,8,0,22),403,Enum.TextXAlignment.Left,Color3.fromRGB(220,220,240),11)
                    tl.TextWrapped=true
                end
                break
            end
        end
    end)
end
BtnCommSend.MouseButton1Click:Connect(function()
    if not curComm then return end
    local txt=CommBox.Text
    if txt=="" then notify(T("comment_warn"),255,190,0) return end
    if txt:lower():find("http") then notify(T("comment_warn_link"),255,50,50) return end
    CommBox.Text=""
    task.spawn(function()
        local raw=ghRaw("scripts.json"); if not raw then notify(T("pub_err"),220,50,50) return end
        local entry='{"author":"'..jEsc(MY_NAME)..'","text":"'..jEsc(txt)..'"}'
        local sc=curComm
        local newRaw=raw:gsub('("id":"'..sc.id..'"[^}]+"comments":)(%d+)',function(a,n) return a..tostring(tonumber(n)+1) end)
        if newRaw:find('"comments_list":%[%]') then
            newRaw=newRaw:gsub('"comments_list":%[%]','"comments_list":['..entry..']',1)
        else
            newRaw=newRaw:gsub('"comments_list":%[','"comments_list":['..entry..',',1)
        end
        local ok=ghWrite("scripts.json",newRaw)
        notify(ok and T("comment_ok") or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
        if ok then openCommentWindow(sc) end
    end)
end)

-- Avaliação
local StarsWindow,_=makeFrame(SGui,UDim2.new(0,300,0,170),UDim2.new(0.5,-150,0.5,-85),Color3.fromRGB(13,13,18),400)
StarsWindow.Visible=false
local StarsTBar,_=makeFrame(StarsWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,30),401)
makeLbl(StarsTBar,T("stars_title"),UDim2.new(1,-40,1,0),UDim2.new(0,12,0,0),402,Enum.TextXAlignment.Left)
makeBtn(StarsTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),402).MouseButton1Click:Connect(function() StarsWindow.Visible=false end)
local StarsDescLbl=makeLbl(StarsWindow,"",UDim2.new(1,-20,0,18),UDim2.new(0,10,0,44),401,Enum.TextXAlignment.Left,Color3.fromRGB(180,180,200),12)
local selStars=0; local starBtns={}
for i=1,5 do
    local sb=makeBtn(StarsWindow,i==5 and "🌟" or "⭐",UDim2.new(0,40,0,40),UDim2.new(0,-10+i*46,0,70),402)
    sb.TextSize=20;sb.BackgroundTransparency=1; table.insert(starBtns,sb)
    sb.MouseButton1Click:Connect(function()
        selStars=i
        for j,b in ipairs(starBtns) do b.BackgroundColor3=j<=i and Color3.fromRGB(60,40,110) or Color3.fromRGB(20,20,30) end
    end)
end
local curStars=nil
makeBtn(StarsWindow,"⭐ Enviar",UDim2.new(1,-20,0,32),UDim2.new(0,10,1,-42),402).MouseButton1Click:Connect(function()
    if not curStars then return end
    if curStars.author:lower()==MY_NAME:lower() then notify(T("stars_own"),255,190,0) return end
    if selStars==0 then notify("⚠️ Selecione!",255,190,0) return end
    StarsWindow.Visible=false
    task.spawn(function()
        local raw=ghRaw("scripts.json"); if not raw then return end
        local sc=curStars; local nl=sc.likes+1; local ns=(sc.stars*sc.likes+selStars)/nl
        local newRaw=raw:gsub('("id":"'..sc.id..'"[^}]+"stars":)([%d%.]+)([^}]+"likes":)(%d+)',
            function(a,_,b,_) return a..string.format("%.1f",ns)..b..nl end)
        local ok=ghWrite("scripts.json",newRaw)
        notify(ok and T("stars_ok") or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
        if ok then loadCommunityScripts() end
    end)
end)

-- Denunciar
local ReportWindow,_=makeFrame(SGui,UDim2.new(0,310,0,170),UDim2.new(0.5,-155,0.5,-85),Color3.fromRGB(13,13,18),400)
ReportWindow.Visible=false
local ReportTBar,_=makeFrame(ReportWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,30),401)
makeLbl(ReportTBar,T("report_title"),UDim2.new(1,-20,1,0),UDim2.new(0,12,0,0),402,Enum.TextXAlignment.Left,nil,13)
local ReportDescLbl=makeLbl(ReportWindow,"",UDim2.new(1,-20,0,44),UDim2.new(0,10,0,44),401,nil,Color3.fromRGB(200,180,180),11)
ReportDescLbl.TextWrapped=true
local curReport=nil
makeBtn(ReportWindow,T("report_confirm"),UDim2.new(0,130,0,34),UDim2.new(0,10,1,-44),402).MouseButton1Click:Connect(function()
    if not curReport then return end; ReportWindow.Visible=false
    task.spawn(function()
        local raw=ghRaw("reports.json") or '{"reports":[],"total":0}'
        local sc=curReport
        local entry='{"id":"'..jEsc(sc.id)..'","name":"'..jEsc(sc.name)..'","author":"'..jEsc(sc.author)..'","reporter":"'..MY_NAME..'","time":"'..os.time()..'"}'
        local newRaw=raw:find('"reports":%[%]') and raw:gsub('"reports":%[%]','"reports":['..entry..']') or raw:gsub('"reports":%[','"reports":['..entry..',')
        local t=tonumber(raw:match('"total":(%d+)')) or 0
        newRaw=newRaw:gsub('"total":%d+','"total":'..tostring(t+1))
        local ok=ghWrite("reports.json",newRaw)
        notify(ok and T("report_ok") or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
    end)
end)
makeBtn(ReportWindow,T("report_cancel"),UDim2.new(0,130,0,34),UDim2.new(1,-140,1,-44),402).MouseButton1Click:Connect(function() ReportWindow.Visible=false end)

-- Admin: lógica dos botões
_G.DH.adminTarget=nil
_G.DH.BtnAdminDel.MouseButton1Click:Connect(function()
    local sc=_G.DH.adminTarget; if not sc then return end
    local pw=_G.DH.AdminPwBox.Text
    if pw~=BAN_PW then notify("❌ Senha errada!",220,50,50) return end
    _G.DH.AdminWindow.Visible=false
    task.spawn(function()
        local raw=ghRaw("scripts.json"); if not raw then notify(T("pub_err"),220,50,50) return end
        local newList={}; local total=0
        for entry in raw:gmatch('\{([^{}]+)\}') do
            local id=entry:match('"id":"([^"]*)"')
            if id and id~=sc.id then table.insert(newList,"{"..entry.."}"); total=total+1 end
        end
        local newRaw='{"scripts":['..table.concat(newList,",")..'],"total":'..total..'}'
        local ok=ghWrite("scripts.json",newRaw)
        notify(ok and "✅ Deletado!" or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
        if ok then loadCommunityScripts() end
    end)
end)
_G.DH.BtnAdminBan.MouseButton1Click:Connect(function()
    local sc=_G.DH.adminTarget; if not sc then return end
    local ok,reason=banUser(sc.author,_G.DH.AdminPwBox.Text)
    if ok then notify("🚫 "..sc.author.." banido!",180,0,180); _G.DH.AdminWindow.Visible=false; loadCommunityScripts()
    elseif reason=="senha_errada" then notify("❌ Senha errada!",220,50,50)
    elseif reason=="ja_banido" then notify("⚠️ Já banido!",255,190,0) end
end)
_G.DH.BtnAdminDelBan.MouseButton1Click:Connect(function()
    local sc=_G.DH.adminTarget; if not sc then return end
    local pw=_G.DH.AdminPwBox.Text
    if pw~=BAN_PW then notify("❌ Senha errada!",220,50,50) return end
    _G.DH.AdminWindow.Visible=false
    task.spawn(function()
        local raw=ghRaw("scripts.json"); if not raw then return end
        local newList={}; local total=0
        for entry in raw:gmatch('\{([^{}]+)\}') do
            local id=entry:match('"id":"([^"]*)"')
            if id and id~=sc.id then table.insert(newList,"{"..entry.."}"); total=total+1 end
        end
        local newRaw='{"scripts":['..table.concat(newList,",")..'],"total":'..total..'}'
        local ok=ghWrite("scripts.json",newRaw)
        if ok then
            banUser(sc.author,pw)
            notify("💀 Deletado + "..sc.author.." banido!",180,0,0)
            loadCommunityScripts()
        end
    end)
end)

-- Publicar
local PublishWindow,_=makeFrame(SGui,UDim2.new(0,370,0,500),UDim2.new(0.5,-185,0.5,-250),Color3.fromRGB(13,13,18),400)
PublishWindow.Visible=false
local PubTBar,_=makeFrame(PublishWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,30),401)
makeLbl(PubTBar,T("pub_title"),UDim2.new(1,-40,1,0),UDim2.new(0,12,0,0),402,Enum.TextXAlignment.Left,nil,14)
makeBtn(PubTBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),402).MouseButton1Click:Connect(function() PublishWindow.Visible=false end)
local function pubLbl(txt,y) return makeLbl(PublishWindow,txt,UDim2.new(1,-30,0,16),UDim2.new(0,15,0,y),401,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11) end
local function pubTB(y,h,ph,green)
    local B=Instance.new("TextBox"); B.Size=UDim2.new(1,-30,0,h); B.Position=UDim2.new(0,15,0,y)
    B.BackgroundColor3=Color3.fromRGB(22,22,30); B.BorderSizePixel=0
    B.PlaceholderText=ph; B.TextColor3=green and Color3.fromRGB(0,210,100) or Color3.fromRGB(240,240,245)
    B.PlaceholderColor3=Color3.fromRGB(100,100,120); B.Font=green and Enum.Font.Code or Enum.Font.Gotham
    B.TextSize=green and 11 or 13; B.ZIndex=401; B.ClearTextOnFocus=false; B.Text=""; B.Parent=PublishWindow
    if green then B.MultiLine=true;B.TextXAlignment=Enum.TextXAlignment.Left;B.TextYAlignment=Enum.TextYAlignment.Top end
    local p=Instance.new("UIPadding",B); p.PaddingLeft=UDim.new(0,10); if green then p.PaddingTop=UDim.new(0,6) end
    return B
end
pubLbl(T("pub_name"),44); local PubNameBox=pubTB(62,32,T("pub_name_ph"),false)
pubLbl(T("pub_code"),102); local PubCodeBox=pubTB(120,110,T("pub_code_ph"),true)
pubLbl(T("pub_game"),238); local PubGameBox=pubTB(256,30,T("pub_game_ph"),false)
pubLbl(T("pub_tags"),294)
local TAGS={
    {"tag_key","🔑"},{"tag_free","✅"},{"tag_autofarm","🌾"},{"tag_esp","👁"},
    {"tag_fly","🕊"},{"tag_speed","⚡"},{"tag_noclip","👻"},{"tag_aimbot","🎯"},
    {"tag_god","🛡"},{"tag_tp","🌀"},{"tag_inf_jump","🦘"},{"tag_kill_all","💀"},
}
local selTags={}
for i,tag in ipairs(TAGS) do
    local row=math.floor((i-1)/4); local col=(i-1)%4
    local TB=makeBtn(PublishWindow,tag[2].." "..T(tag[1]),UDim2.new(0,78,0,24),UDim2.new(0,15+col*86,0,312+row*28),402)
    TB.TextSize=9
    local tk=tag[1]
    TB.MouseButton1Click:Connect(function()
        selTags[tk]=not selTags[tk]
        TB.BackgroundColor3=selTags[tk] and Color3.fromRGB(60,40,110) or Color3.fromRGB(20,20,30)
    end)
end
makeBtn(PublishWindow,T("pub_cancel"),UDim2.new(0,155,0,34),UDim2.new(1,-165,1,-44),402).MouseButton1Click:Connect(function() PublishWindow.Visible=false end)
makeBtn(PublishWindow,T("pub_btn"),UDim2.new(0,155,0,34),UDim2.new(0,10,1,-44),402).MouseButton1Click:Connect(function()
    local nm=PubNameBox.Text; local cd=PubCodeBox.Text
    if nm=="" then notify(T("pub_warn_name"),255,190,0) return end
    if cd=="" then notify(T("pub_warn_code"),255,190,0) return end
    if isJunk(nm,cd) then notify(T("pub_warn_junk"),255,80,0) return end
    if isBanned(MY_NAME) then notify("🚫 Você está banido!",220,50,50) return end
    local tags=""
    for k,v in pairs(selTags) do if v then tags=tags..k.."," end end
    local week=os.date and os.date("%Y-W%V") or "2026"
    local entry='{"id":"'..jEsc(MY_NAME.."_"..os.time())..'","name":"'..jEsc(nm)..'","author":"'..MY_NAME..'","code":"'..jEsc(cd)..'","gameId":"'..jEsc(PubGameBox.Text)..'","tags":"'..tags..'","likes":0,"stars":0,"comments":0,"comments_list":[],"week":"'..week..'"}'
    PublishWindow.Visible=false; notify("📤 Publicando...",110,60,255)
    task.spawn(function()
        local raw=ghRaw("scripts.json") or '{"scripts":[],"total":0}'
        local total=(tonumber(raw:match('"total":(%d+)')) or 0)+1
        local newRaw=raw:find('"scripts":%[%]') and raw:gsub('"scripts":%[%]','"scripts":['..entry..']') or raw:gsub('"scripts":%[','"scripts":['..entry..',')
        newRaw=newRaw:gsub('"total":%d+','"total":'..total)
        local ok=ghWrite("scripts.json",newRaw)
        notify(ok and T("pub_ok") or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
        if ok then PubNameBox.Text="";PubCodeBox.Text="";PubGameBox.Text="";selTags={};loadCommunityScripts() end
    end)
end)

BtnNewPublic.MouseButton1Click:Connect(function()
    if isBanned(MY_NAME) then notify("🚫 Você está banido!",220,50,50) return end
    PubNameBox.Text="";PubCodeBox.Text="";PubGameBox.Text="";selTags={}
    PublishWindow.Visible=true
end)

-- ======= VOTAÇÃO DE JOGOS =======
local VoteAddWindow=nil
if isAdmin() then
    VoteAddWindow,_=makeFrame(SGui,UDim2.new(0,340,0,320),UDim2.new(0.5,-170,0.5,-160),Color3.fromRGB(13,13,18),400)
    VoteAddWindow.Visible=false
    local VATBar,_=makeFrame(VoteAddWindow,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(20,20,30),401)
    makeLbl(VATBar,"➕ Nova Votação",UDim2.new(1,-40,1,0),UDim2.new(0,12,0,0),402,Enum.TextXAlignment.Left,nil,13)
    makeBtn(VATBar,"✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),402).MouseButton1Click:Connect(function() VoteAddWindow.Visible=false end)
    makeLbl(VoteAddWindow,"Nome do Jogo:",UDim2.new(1,-20,0,16),UDim2.new(0,10,0,44),401,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
    local VAGameBox=Instance.new("TextBox"); VAGameBox.Size=UDim2.new(1,-20,0,32); VAGameBox.Position=UDim2.new(0,10,0,62)
    VAGameBox.BackgroundColor3=Color3.fromRGB(22,22,30); VAGameBox.BorderSizePixel=0
    VAGameBox.PlaceholderText="Ex: Brookhaven"; VAGameBox.TextColor3=Color3.fromRGB(240,240,245)
    VAGameBox.PlaceholderColor3=Color3.fromRGB(100,100,120); VAGameBox.Font=Enum.Font.Gotham
    VAGameBox.TextSize=13; VAGameBox.ZIndex=401; VAGameBox.ClearTextOnFocus=false; VAGameBox.Text=""; VAGameBox.Parent=VoteAddWindow
    Instance.new("UIPadding",VAGameBox).PaddingLeft=UDim.new(0,10)
    makeLbl(VoteAddWindow,"Script (Lua):",UDim2.new(1,-20,0,16),UDim2.new(0,10,0,102),401,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
    local VACodeBox=Instance.new("TextBox"); VACodeBox.Size=UDim2.new(1,-20,0,120); VACodeBox.Position=UDim2.new(0,10,0,120)
    VACodeBox.BackgroundColor3=Color3.fromRGB(12,18,12); VACodeBox.BorderSizePixel=0
    VACodeBox.PlaceholderText="-- Script para votação..."; VACodeBox.TextColor3=Color3.fromRGB(0,210,100)
    VACodeBox.PlaceholderColor3=Color3.fromRGB(60,100,60); VACodeBox.Font=Enum.Font.Code
    VACodeBox.TextSize=11; VACodeBox.MultiLine=true; VACodeBox.TextXAlignment=Enum.TextXAlignment.Left
    VACodeBox.TextYAlignment=Enum.TextYAlignment.Top; VACodeBox.ZIndex=401; VACodeBox.ClearTextOnFocus=false
    VACodeBox.Text=""; VACodeBox.Parent=VoteAddWindow
    local vap=Instance.new("UIPadding",VACodeBox); vap.PaddingLeft=UDim.new(0,8); vap.PaddingTop=UDim.new(0,6)
    makeLbl(VoteAddWindow,"Senha Admin:",UDim2.new(1,-20,0,16),UDim2.new(0,10,0,248),401,Enum.TextXAlignment.Left,Color3.fromRGB(140,140,165),11)
    local VAPwBox=Instance.new("TextBox"); VAPwBox.Size=UDim2.new(1,-20,0,30); VAPwBox.Position=UDim2.new(0,10,0,266)
    VAPwBox.BackgroundColor3=Color3.fromRGB(30,15,15); VAPwBox.BorderSizePixel=0
    VAPwBox.PlaceholderText="Senha..."; VAPwBox.TextColor3=Color3.fromRGB(255,180,180)
    VAPwBox.PlaceholderColor3=Color3.fromRGB(100,80,80); VAPwBox.Font=Enum.Font.Code
    VAPwBox.TextSize=12; VAPwBox.ZIndex=401; VAPwBox.ClearTextOnFocus=false; VAPwBox.Text=""; VAPwBox.Parent=VoteAddWindow
    Instance.new("UIPadding",VAPwBox).PaddingLeft=UDim.new(0,10)
    makeBtn(VoteAddWindow,"📤 Publicar Votação",UDim2.new(1,-20,0,34),UDim2.new(0,10,1,-10),402).MouseButton1Click:Connect(function()
        if VAPwBox.Text~=BAN_PW then notify("❌ Senha errada!",220,50,50) return end
        if VAGameBox.Text=="" then notify("⚠️ Nome vazio!",255,190,0) return end
        local entry='{"id":"vote_'..os.time()..'","game":"'..jEsc(VAGameBox.Text)..'","code":"'..jEsc(VACodeBox.Text)..'","votes":{"great":0,"yes":0,"no":0},"voted":[]}'
        VoteAddWindow.Visible=false; notify("📤 Publicando votação...",110,60,255)
        task.spawn(function()
            local raw=ghRaw("votes.json") or '{"votes":[],"total":0}'
            local total=(tonumber(raw:match('"total":(%d+)')) or 0)+1
            local newRaw=raw:find('"votes":%[%]') and raw:gsub('"votes":%[%]','"votes":['..entry..']') or raw:gsub('"votes":%[','"votes":['..entry..',')
            newRaw=newRaw:gsub('"total":%d+','"total":'..total)
            local ok=ghWrite("votes.json",newRaw)
            notify(ok and "✅ Votação publicada!" or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
            if ok then loadVotes() end
        end)
    end)
    if BtnVoteAdd then
        BtnVoteAdd.MouseButton1Click:Connect(function() VoteAddWindow.Visible=true; VAGameBox.Text=""; VACodeBox.Text=""; VAPwBox.Text="" end)
    end
end

local function loadVotes()
    VoteEmptyLbl.Text=T("vote_loading"); VoteEmptyLbl.Visible=true
    task.spawn(function()
        local raw=ghRaw("votes.json")
        for _,c in pairs(VoteScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        if not raw or not raw:find('"votes"') then
            VoteEmptyLbl.Text=T("vote_empty"); return
        end
        local found=false
        for entry in raw:gmatch('\{([^{}]+)\}') do
            local id   =entry:match('"id":"([^"]*)"')
            local game =entry:match('"game":"([^"]*)"')
            local code =entry:match('"code":"([^"]*)"')
            if id and game then
                found=true
                local great=tonumber(entry:match('"great":(%d+)')) or 0
                local yes  =tonumber(entry:match('"yes":(%d+)')) or 0
                local no   =tonumber(entry:match('"no":(%d+)')) or 0
                -- Verifica se eu já votei
                local myVoted=(entry:match('"voted":%[(.-)%]') or ""):find('"'..MY_NAME:lower()..'"') ~= nil
                local Card,_=makeFrame(VoteScroll,UDim2.new(1,0,0,96),nil,Color3.fromRGB(20,20,30),4)
                makeLbl(Card,"🎮 "..game,UDim2.new(1,-16,0,22),UDim2.new(0,10,0,6),5,Enum.TextXAlignment.Left,nil,13)
                -- Contagem
                local statsStr=T("vote_great")..": "..great.."   "..T("vote_yes")..": "..yes.."   "..T("vote_no")..": "..no
                makeLbl(Card,statsStr,UDim2.new(1,-16,0,16),UDim2.new(0,10,0,32),5,Enum.TextXAlignment.Left,Color3.fromRGB(160,155,200),10)
                -- Botões de voto
                local BG=makeBtn(Card,T("vote_great"),UDim2.new(0,90,0,28),UDim2.new(0,8,0,54),5)
                local BY=makeBtn(Card,T("vote_yes"),  UDim2.new(0,70,0,28),UDim2.new(0,106,0,54),5)
                local BN=makeBtn(Card,T("vote_no"),   UDim2.new(0,60,0,28),UDim2.new(0,184,0,54),5)
                BG.TextSize=10;BY.TextSize=10;BN.TextSize=10
                if myVoted then
                    BG.BackgroundColor3=Color3.fromRGB(30,30,40); BY.BackgroundColor3=Color3.fromRGB(30,30,40)
                    BN.BackgroundColor3=Color3.fromRGB(30,30,40)
                end
                -- Botão exec (se tiver script)
                if code and code~="" then
                    local BX=makeBtn(Card,"▶",UDim2.new(0,28,0,28),UDim2.new(1,-38,0,54),5)
                    BX.TextSize=12
                    BX.MouseButton1Click:Connect(function()
                        local c2=code:gsub("\\n","\n"):gsub('\\"','"')
                        local ok,err=pcall(function() local fn=loadstring(c2); if fn then fn() end end)
                        notify(ok and T("exec_ok") or T("exec_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
                    end)
                end
                -- Admin: deletar votação
                if isAdmin() then
                    local BDA=makeBtn(Card,"🗑",UDim2.new(0,28,0,28),UDim2.new(0,260,0,54),5)
                    BDA.BackgroundColor3=Color3.fromRGB(80,20,20); BDA.TextSize=10
                    local vid=id
                    BDA.MouseButton1Click:Connect(function()
                        task.spawn(function()
                            local pw=_G.DH.AdminPwBox and _G.DH.AdminPwBox.Text or ""
                            -- abre janela de confirmação simples
                            notify("🗑 Deletando votação...",110,60,255)
                            local raw2=ghRaw("votes.json"); if not raw2 then return end
                            local newList={}; local total=0
                            for e2 in raw2:gmatch('\{([^{}]+)\}') do
                                local eid=e2:match('"id":"([^"]*)"')
                                if eid and eid~=vid then table.insert(newList,"{"..e2.."}"); total=total+1 end
                            end
                            local newRaw2='{"votes":['..table.concat(newList,",")..'],"total":'..total..'}'
                            local ok=ghWrite("votes.json",newRaw2)
                            notify(ok and "✅ Deletado!" or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
                            if ok then loadVotes() end
                        end)
                    end)
                end
                local function castVote(vtype)
                    if myVoted then notify(T("vote_already"),255,190,0) return end
                    task.spawn(function()
                        local raw2=ghRaw("votes.json"); if not raw2 then return end
                        local vid2=id
                        local newRaw2=raw2:gsub('("id":"'..vid2..'"[^)]-"'..vtype..'":)(%d+)',function(a,n) return a..tostring(tonumber(n)+1) end)
                        -- Adiciona meu nome na lista voted
                        if newRaw2:find('"voted":%[%]') then
                            newRaw2=newRaw2:gsub('"voted":%[%]','"voted":["'..MY_NAME:lower()..'"]',1)
                        else
                            newRaw2=newRaw2:gsub('"voted":%[','"voted":["'..MY_NAME:lower()..'",',1)
                        end
                        local ok=ghWrite("votes.json",newRaw2)
                        notify(ok and T("vote_done") or T("pub_err"),ok and 0 or 220,ok and 180 or 50,ok and 80 or 50)
                        if ok then loadVotes() end
                    end)
                end
                BG.MouseButton1Click:Connect(function() castVote("great") end)
                BY.MouseButton1Click:Connect(function() castVote("yes") end)
                BN.MouseButton1Click:Connect(function() castVote("no") end)
            end
        end
        VoteEmptyLbl.Visible=not found
        if not found then VoteEmptyLbl.Text=T("vote_empty") end
    end)
end

-- ======= BOTÕES TITLEBAR: LÓGICA =======
BtnClose.MouseButton1Click:Connect(function() Main:Destroy() end)
BtnMinimize.MouseButton1Click:Connect(function()
    Content.Visible=not Content.Visible
    Main.Size=Content.Visible and UDim2.new(0,WINDOW_W,0,WINDOW_H) or UDim2.new(0,WINDOW_W,0,40)
end)
BtnCfg.MouseButton1Click:Connect(function() _G.DH.CfgWindow.Visible=true end)
BtnSearch.MouseButton1Click:Connect(function() _G.DH.SearchWindow.Visible=true end)
BtnGames.MouseButton1Click:Connect(function()
    if gamesMode then showScripts() else showGames() end
end)
BtnCommunity.MouseButton1Click:Connect(function()
    if communityMode then showScripts()
    else showView(CommunityView); communityMode=true; loadCommunityScripts() end
end)
BtnVote.MouseButton1Click:Connect(function()
    if voteMode then showScripts()
    else showView(VoteView); voteMode=true; loadVotes() end
end)
BtnNew.MouseButton1Click:Connect(function() _G.DH.openEditor("","") end)
BtnGamesBack.MouseButton1Click:Connect(showScripts)

-- ======= REFRESH UI (idioma) =======
_G.DH.refreshUI=function()
    TitleLbl.Text=T("title"); BetaLbl.Text=T("beta")
    BtnNew.Text="＋"; BtnGames.Text="🎮"; BtnCommunity.Text="🌐"; BtnVote.Text="👥"
    CommTitleLbl.Text=T("community_title"); BtnNewPublic.Text=T("community_new")
    VoteTitleLbl.Text=T("vote_title")
    refreshScripts()
end

-- ======= INICIA =======
refreshScripts()
_G.DH.Main=Main
_G.DH.showScripts=showScripts
