-- DeltaHub PARTE 2: Config + Traduções + UI Base
local player = _G.DH.player
local TS = _G.DH.TS

-- ======= CONFIG =======
local CONFIG_FILE = "DeltaHub/config.json"
local function saveConfig(lang, border)
    writefile(CONFIG_FILE, '{"lang":"'..lang..'","border":"'..border..'"}')
end
local function loadConfig()
    if isfile(CONFIG_FILE) then
        local r = readfile(CONFIG_FILE)
        local lang   = r:match('"lang":"([^"]+)"') or "pt_BR"
        local border = r:match('"border":"([^"]+)"') or "rgb"
        return lang, border
    end
    return "pt_BR", "rgb"
end
_G.DH.saveConfig = saveConfig
_G.DH.loadConfig = loadConfig
local lang, borderMode = loadConfig()
_G.DH.lang = lang
_G.DH.borderMode = borderMode

-- ======= SCRIPTS LOCAIS =======
local SCRIPTS_PATH = "DeltaHub/scripts/"
if not isfolder("DeltaHub/") then makefolder("DeltaHub/") end
if not isfolder(SCRIPTS_PATH) then makefolder(SCRIPTS_PATH) end
_G.DH.SCRIPTS_PATH = SCRIPTS_PATH
_G.DH.saveScript = function(name, code) writefile(SCRIPTS_PATH..name..".lua", code) end
_G.DH.deleteScript = function(name)
    local p = SCRIPTS_PATH..name..".lua"
    if isfile(p) then delfile(p) end
end
_G.DH.getAllScripts = function()
    local t = {}
    for _, path in pairs(listfiles(SCRIPTS_PATH)) do
        local name = path:gsub(SCRIPTS_PATH,""):gsub("%.lua$","")
        table.insert(t, {name=name, code=readfile(path)})
    end
    return t
end

-- ======= TRADUÇÕES =======
local LANG = {
    pt_BR = {
        title="Delta Hub", beta="beta", no_scripts="Nenhum script salvo.",
        btn_new="＋ Novo", btn_run="▶ Executar", btn_edit="✏ Editar",
        btn_delete="🗑 Deletar", btn_copy="⧉ Copiar",
        editor_title="Editor de Scripts", editor_new="Novo Script",
        editor_name="Nome:", editor_code="Código:",
        editor_save="💾 Salvar", editor_cancel="✕ Cancelar",
        editor_run="▶ Executar", editor_nameph="Nome do script...",
        del_title="Confirmar exclusão", del_msg="Deletar ",
        del_confirm="🗑 Deletar", del_cancel="✕ Cancelar",
        cfg_title="Configurações", cfg_lang="Idioma:",
        cfg_border="Borda:", cfg_save="💾 Salvar", cfg_close="✕ Fechar",
        search_ph="Pesquisar scripts...",
        games_title="🎮 Jogos", game_iy="Infinite Yield",
        game_iy_script="Script de admin universal",
        game_iy_tag="✨ DESTAQUE", game_mm2="Murder Mystery 2",
        game_yarhm="YARHM - Yet Another RH Module",
        game_run="▶ Executar", games_back="← Voltar",
        iy_confirm="Executar Infinite Yield?",
        yarhm_confirm="Executar YARHM para MM2?",
        community_title="🌐 Comunidade", community_new="＋ Novo Script Público",
        community_empty="Nenhum script publicado ainda.\nSeja o primeiro!",
        community_loading="Carregando scripts...",
        pub_title="📤 Publicar Script", pub_name="Nome do Script:",
        pub_name_ph="Ex: Fly Hack v2", pub_code="Código (Lua):",
        pub_code_ph="-- Cole seu script aqui...",
        pub_game="ID do Jogo (opcional):", pub_game_ph="Ex: 142823291",
        pub_tags="Funcionalidades:", pub_btn="📤 Publicar",
        pub_cancel="✕ Cancelar", pub_warn_name="⚠️ Dê um nome ao script!",
        pub_warn_code="⚠️ O código está vazio!",
        pub_warn_junk="⚠️ Script inválido ou sem conteúdo!",
        pub_ok="✅ Script publicado!", pub_err="❌ Erro ao publicar!",
        exec_title="▶ Executar Script", exec_confirm="▶ Executar",
        exec_cancel="✕ Cancelar", exec_ok="✅ Executado!",
        exec_err="❌ Erro ao executar!",
        report_title="🚨 Denunciar Script", report_confirm="🚨 Denunciar",
        report_cancel="✕ Cancelar", report_ok="✅ Denúncia enviada!",
        comment_title="💬 Comentários", comment_ph="Escreva um comentário...",
        comment_send="Enviar", comment_warn="⚠️ Comentário vazio!",
        comment_warn_link="⚠️ Links não são permitidos!",
        comment_ok="✅ Comentário enviado!",
        stars_title="⭐ Avaliar Script",
        stars_own="⚠️ Você não pode avaliar seu próprio script!",
        stars_ok="✅ Avaliação enviada!",
        btn_exec="▶", btn_comment="💬", btn_report="🚨", btn_stars="⭐",
        tag_key="🔑 Key", tag_autofarm="🌾 Auto Farm", tag_esp="👁 ESP",
        tag_fly="🕊 Fly", tag_speed="⚡ Speed", tag_noclip="👻 NoClip",
        tag_inf_jump="🦘 Inf Jump", tag_aimbot="🎯 Aimbot",
        tag_kill_all="💀 Kill All", tag_god="🛡 God Mode",
        tag_tp="🌀 Teleport", tag_free="✅ Free",
        vote_title="👥 Votar Scripts", vote_great="🌟 Ótimo",
        vote_yes="⭐ Sim", vote_no="👎 Não",
        vote_loading="Carregando votações...",
        vote_empty="Nenhuma votação disponível.",
        vote_done="✅ Voto registrado!",
        vote_already="⚠️ Você já votou neste!",
    },
    en_US = {
        title="Delta Hub", beta="beta", no_scripts="No saved scripts.",
        btn_new="＋ New", btn_run="▶ Run", btn_edit="✏ Edit",
        btn_delete="🗑 Delete", btn_copy="⧉ Copy",
        editor_title="Script Editor", editor_new="New Script",
        editor_name="Name:", editor_code="Code:",
        editor_save="💾 Save", editor_cancel="✕ Cancel",
        editor_run="▶ Run", editor_nameph="Script name...",
        del_title="Confirm delete", del_msg="Delete ",
        del_confirm="🗑 Delete", del_cancel="✕ Cancel",
        cfg_title="Settings", cfg_lang="Language:",
        cfg_border="Border:", cfg_save="💾 Save", cfg_close="✕ Close",
        search_ph="Search scripts...",
        games_title="🎮 Games", game_iy="Infinite Yield",
        game_iy_script="Universal admin script",
        game_iy_tag="✨ FEATURED", game_mm2="Murder Mystery 2",
        game_yarhm="YARHM - Yet Another RH Module",
        game_run="▶ Run", games_back="← Back",
        iy_confirm="Run Infinite Yield?",
        yarhm_confirm="Run YARHM for MM2?",
        community_title="🌐 Community", community_new="＋ New Public Script",
        community_empty="No scripts published yet.\nBe the first!",
        community_loading="Loading scripts...",
        pub_title="📤 Publish Script", pub_name="Script Name:",
        pub_name_ph="Ex: Fly Hack v2", pub_code="Code (Lua):",
        pub_code_ph="-- Paste your script here...",
        pub_game="Game ID (optional):", pub_game_ph="Ex: 142823291",
        pub_tags="Features:", pub_btn="📤 Publish",
        pub_cancel="✕ Cancel", pub_warn_name="⚠️ Enter a name!",
        pub_warn_code="⚠️ Code is empty!",
        pub_warn_junk="⚠️ Invalid script!",
        pub_ok="✅ Script published!", pub_err="❌ Publish error!",
        exec_title="▶ Execute Script", exec_confirm="▶ Execute",
        exec_cancel="✕ Cancel", exec_ok="✅ Executed!",
        exec_err="❌ Execution error!",
        report_title="🚨 Report Script", report_confirm="🚨 Report",
        report_cancel="✕ Cancel", report_ok="✅ Report sent!",
        comment_title="💬 Comments", comment_ph="Write a comment...",
        comment_send="Send", comment_warn="⚠️ Empty comment!",
        comment_warn_link="⚠️ Links not allowed!",
        comment_ok="✅ Comment sent!",
        stars_title="⭐ Rate Script",
        stars_own="⚠️ Can't rate your own script!",
        stars_ok="✅ Rating sent!",
        btn_exec="▶", btn_comment="💬", btn_report="🚨", btn_stars="⭐",
        tag_key="🔑 Key", tag_autofarm="🌾 Auto Farm", tag_esp="👁 ESP",
        tag_fly="🕊 Fly", tag_speed="⚡ Speed", tag_noclip="👻 NoClip",
        tag_inf_jump="🦘 Inf Jump", tag_aimbot="🎯 Aimbot",
        tag_kill_all="💀 Kill All", tag_god="🛡 God Mode",
        tag_tp="🌀 Teleport", tag_free="✅ Free",
        vote_title="👥 Vote Scripts", vote_great="🌟 Great",
        vote_yes="⭐ Yes", vote_no="👎 No",
        vote_loading="Loading votes...",
        vote_empty="No votes available.",
        vote_done="✅ Vote registered!",
        vote_already="⚠️ You already voted on this!",
    },
    es_ES = {
        title="Delta Hub", beta="beta", no_scripts="Sin scripts guardados.",
        btn_new="＋ Nuevo", btn_run="▶ Ejecutar", btn_edit="✏ Editar",
        btn_delete="🗑 Eliminar", btn_copy="⧉ Copiar",
        editor_title="Editor de Scripts", editor_new="Nuevo Script",
        editor_name="Nombre:", editor_code="Código:",
        editor_save="💾 Guardar", editor_cancel="✕ Cancelar",
        editor_run="▶ Ejecutar", editor_nameph="Nombre del script...",
        del_title="Confirmar eliminación", del_msg="¿Eliminar ",
        del_confirm="🗑 Eliminar", del_cancel="✕ Cancelar",
        cfg_title="Configuración", cfg_lang="Idioma:",
        cfg_border="Borde:", cfg_save="💾 Guardar", cfg_close="✕ Cerrar",
        search_ph="Buscar scripts...",
        games_title="🎮 Juegos", game_iy="Infinite Yield",
        game_iy_script="Script admin universal",
        game_iy_tag="✨ DESTACADO", game_mm2="Murder Mystery 2",
        game_yarhm="YARHM - Yet Another RH Module",
        game_run="▶ Ejecutar", games_back="← Volver",
        iy_confirm="¿Ejecutar Infinite Yield?",
        yarhm_confirm="¿Ejecutar YARHM para MM2?",
        community_title="🌐 Comunidad", community_new="＋ Nuevo Script Público",
        community_empty="Sin scripts publicados.\n¡Sé el primero!",
        community_loading="Cargando scripts...",
        pub_title="📤 Publicar Script", pub_name="Nombre:",
        pub_name_ph="Ej: Fly Hack v2", pub_code="Código (Lua):",
        pub_code_ph="-- Pega tu script aquí...",
        pub_game="ID del Juego (opcional):", pub_game_ph="Ej: 142823291",
        pub_tags="Funciones:", pub_btn="📤 Publicar",
        pub_cancel="✕ Cancelar", pub_warn_name="⚠️ Escribe un nombre!",
        pub_warn_code="⚠️ El código está vacío!",
        pub_warn_junk="⚠️ Script inválido!",
        pub_ok="✅ ¡Script publicado!", pub_err="❌ Error al publicar!",
        exec_title="▶ Ejecutar Script", exec_confirm="▶ Ejecutar",
        exec_cancel="✕ Cancelar", exec_ok="✅ ¡Ejecutado!",
        exec_err="❌ Error!",
        report_title="🚨 Denunciar Script", report_confirm="🚨 Denunciar",
        report_cancel="✕ Cancelar", report_ok="✅ Denuncia enviada!",
        comment_title="💬 Comentarios", comment_ph="Escribe un comentario...",
        comment_send="Enviar", comment_warn="⚠️ Comentario vacío!",
        comment_warn_link="⚠️ ¡Links no permitidos!",
        comment_ok="✅ Comentario enviado!",
        stars_title="⭐ Calificar Script",
        stars_own="⚠️ No puedes calificar tu script!",
        stars_ok="✅ Calificación enviada!",
        btn_exec="▶", btn_comment="💬", btn_report="🚨", btn_stars="⭐",
        tag_key="🔑 Key", tag_autofarm="🌾 Auto Farm", tag_esp="👁 ESP",
        tag_fly="🕊 Fly", tag_speed="⚡ Speed", tag_noclip="👻 NoClip",
        tag_inf_jump="🦘 Inf Jump", tag_aimbot="🎯 Aimbot",
        tag_kill_all="💀 Kill All", tag_god="🛡 God Mode",
        tag_tp="🌀 Teleport", tag_free="✅ Free",
        vote_title="👥 Votar Scripts", vote_great="🌟 Excelente",
        vote_yes="⭐ Sí", vote_no="👎 No",
        vote_loading="Cargando votaciones...",
        vote_empty="Sin votaciones disponibles.",
        vote_done="✅ ¡Voto registrado!",
        vote_already="⚠️ ¡Ya votaste en esto!",
    },
    ja_JP = {
        title="Delta Hub", beta="beta", no_scripts="スクリプトなし。",
        btn_new="＋ 新規", btn_run="▶ 実行", btn_edit="✏ 編集",
        btn_delete="🗑 削除", btn_copy="⧉ コピー",
        editor_title="スクリプトエディタ", editor_new="新しいスクリプト",
        editor_name="名前:", editor_code="コード:",
        editor_save="💾 保存", editor_cancel="✕ キャンセル",
        editor_run="▶ 実行", editor_nameph="スクリプト名...",
        del_title="削除確認", del_msg="削除: ",
        del_confirm="🗑 削除", del_cancel="✕ キャンセル",
        cfg_title="設定", cfg_lang="言語:",
        cfg_border="ボーダー:", cfg_save="💾 保存", cfg_close="✕ 閉じる",
        search_ph="スクリプトを検索...",
        games_title="🎮 ゲーム", game_iy="Infinite Yield",
        game_iy_script="ユニバーサル管理スクリプト",
        game_iy_tag="✨ 注目", game_mm2="Murder Mystery 2",
        game_yarhm="YARHM - Yet Another RH Module",
        game_run="▶ 実行", games_back="← 戻る",
        iy_confirm="Infinite Yieldを実行?",
        yarhm_confirm="MM2用YARHMを実行?",
        community_title="🌐 コミュニティ", community_new="＋ 新しい公開スクリプト",
        community_empty="スクリプトなし。\n最初に投稿しよう！",
        community_loading="読み込み中...",
        pub_title="📤 スクリプト公開", pub_name="名前:",
        pub_name_ph="例: フライハック v2", pub_code="コード (Lua):",
        pub_code_ph="-- ここに貼り付け...",
        pub_game="ゲームID (任意):", pub_game_ph="例: 142823291",
        pub_tags="機能:", pub_btn="📤 公開",
        pub_cancel="✕ キャンセル", pub_warn_name="⚠️ 名前を入力!",
        pub_warn_code="⚠️ コードが空!", pub_warn_junk="⚠️ 無効なスクリプト!",
        pub_ok="✅ 公開完了!", pub_err="❌ エラー!",
        exec_title="▶ スクリプト実行", exec_confirm="▶ 実行",
        exec_cancel="✕ キャンセル", exec_ok="✅ 実行完了!",
        exec_err="❌ エラー!",
        report_title="🚨 通報", report_confirm="🚨 通報する",
        report_cancel="✕ キャンセル", report_ok="✅ 通報完了!",
        comment_title="💬 コメント", comment_ph="コメントを書く...",
        comment_send="送信", comment_warn="⚠️ コメントが空!",
        comment_warn_link="⚠️ リンク不可!", comment_ok="✅ コメント送信!",
        stars_title="⭐ 評価", stars_own="⚠️ 自分のスクリプトは評価不可!",
        stars_ok="✅ 評価完了!",
        btn_exec="▶", btn_comment="💬", btn_report="🚨", btn_stars="⭐",
        tag_key="🔑 Key", tag_autofarm="🌾 Auto Farm", tag_esp="👁 ESP",
        tag_fly="🕊 Fly", tag_speed="⚡ Speed", tag_noclip="👻 NoClip",
        tag_inf_jump="🦘 Inf Jump", tag_aimbot="🎯 Aimbot",
        tag_kill_all="💀 Kill All", tag_god="🛡 God Mode",
        tag_tp="🌀 Teleport", tag_free="✅ Free",
        vote_title="👥 投票", vote_great="🌟 最高",
        vote_yes="⭐ はい", vote_no="👎 いいえ",
        vote_loading="読み込み中...",
        vote_empty="投票なし。",
        vote_done="✅ 投票完了!",
        vote_already="⚠️ すでに投票済み!",
    }
}
_G.DH.LANG = LANG
_G.DH.lang = lang
local function T(k)
    local t = _G.DH.LANG[_G.DH.lang]
    return (t and t[k]) or (LANG.pt_BR[k]) or k
end
_G.DH.T = T

-- ======= HELPERS UI =======
local function makeFrame(parent, size, pos, color, z)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    if pos then f.Position = pos end
    f.BackgroundColor3 = color or Color3.fromRGB(18,18,26)
    f.BorderSizePixel = 0; f.ZIndex = z or 2
    f.Parent = parent
    local s = Instance.new("UIStroke"); s.Thickness=1.5
    s.Color=Color3.fromRGB(50,40,80); s.Parent=f
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,8); c.Parent=f
    return f, s
end

local function makeLbl(parent, text, size, pos, z, align, color, ts)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1,0,0,28)
    if pos then l.Position = pos end
    l.BackgroundTransparency = 1
    l.Text = text or ""; l.ZIndex = z or 3
    l.Font = Enum.Font.GothamBold; l.TextSize = ts or 13
    l.TextColor3 = color or Color3.fromRGB(230,225,255)
    l.TextXAlignment = align or Enum.TextXAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent; return l
end

local function makeBtn(parent, text, size, pos, z)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(0,80,0,30)
    if pos then b.Position = pos end
    b.BackgroundColor3 = Color3.fromRGB(20,20,30); b.BorderSizePixel=0
    b.Text = text or ""; b.ZIndex = z or 3
    b.Font = Enum.Font.GothamBold; b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(220,215,255)
    b.AutoButtonColor = true; b.Parent = parent
    local s = Instance.new("UIStroke"); s.Thickness=1.2
    s.Color=Color3.fromRGB(80,60,140); s.Parent=b
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,7); c.Parent=b
    return b
end

local function makeScroll(parent, size, pos, z)
    local s = Instance.new("ScrollingFrame")
    s.Size = size or UDim2.new(1,0,1,0)
    if pos then s.Position = pos end
    s.BackgroundTransparency = 1
    s.ScrollBarThickness = 4
    s.ScrollBarImageColor3 = Color3.fromRGB(110,60,255)
    s.BorderSizePixel = 0; s.ZIndex = z or 3
    s.CanvasSize = UDim2.new(0,0,0,0); s.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,6); layout.Parent = s
    layout.Changed:Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
    pad.PaddingTop=UDim.new(0,6); pad.Parent=s
    return s
end

local function notify(msg, r, g, b)
    local SGui = _G.DH.ScreenGui
    if not SGui then return end
    local nf = Instance.new("Frame")
    nf.Size=UDim2.new(0,240,0,44); nf.BackgroundColor3=Color3.fromRGB(r or 110,g or 60,b or 255)
    nf.Position=UDim2.new(0.5,-120,-0.05,0); nf.BorderSizePixel=0; nf.ZIndex=9999; nf.Parent=SGui
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,8)
    local nl=Instance.new("TextLabel",nf); nl.Size=UDim2.new(1,0,1,0)
    nl.BackgroundTransparency=1; nl.Text=msg; nl.Font=Enum.Font.GothamBold
    nl.TextSize=13; nl.TextColor3=Color3.fromRGB(255,255,255); nl.ZIndex=10000
    local ts=game:GetService("TweenService")
    ts:Create(nf,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-120,0.02,0)}):Play()
    task.delay(2.2, function()
        ts:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-120,-0.1,0)}):Play()
        task.wait(0.35); pcall(function() nf:Destroy() end)
    end)
end

_G.DH.makeFrame  = makeFrame
_G.DH.makeLbl    = makeLbl
_G.DH.makeBtn    = makeBtn
_G.DH.makeScroll = makeScroll
_G.DH.notify     = notify
