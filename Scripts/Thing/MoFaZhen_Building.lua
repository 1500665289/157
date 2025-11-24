local tbThing = GameMain:GetMod("ThingHelper"):GetThing("MoFaZhen_Building");

-- 点击建筑
function tbThing:OnPutDown()
    -- 简化按钮管理，避免重复操作
    self.it:AddBtnData("输出", nil, "bind.luaclass:GetTable():SelectNpcOut()", "使用魔法阵灵气补充自身灵气", nil);
    self.it:AddBtnData("输入", nil, "bind.luaclass:GetTable():SelectNpcIn()", "输出自身二分之一灵气进入魔法阵", nil);
end

-- 使用、查询内门NPC
function tbThing:SelectNpcOut()
    CS.Wnd_SelectNpc.Instance:Select(
        WorldLua:GetSelectNpcCallback(function(rs)
            if (rs == nil or rs.Count == 0) then
                return
            end
            local npc = ThingMgr:FindThingByID(rs[0])
            if npc and npc.MaxLing then  -- 添加有效性检查
                self:OutLing(npc)
            end
        end),
        g_emNpcRank.Disciple, 1, 1, nil, nil, "选择角色")
end

function tbThing:SelectNpcIn()
    CS.Wnd_SelectNpc.Instance:Select(
        WorldLua:GetSelectNpcCallback(function(rs)
            if (rs == nil or rs.Count == 0) then
                return
            end
            local npc = ThingMgr:FindThingByID(rs[0])
            if npc and npc.LingV then  -- 添加有效性检查
                self:InLing(npc)
            end
        end),
        g_emNpcRank.Disciple, 1, 1, nil, nil, "选择角色")
end

function tbThing:OutLing(npc)
    -- 添加参数检查
    if not npc or not npc.MaxLing or not self.it or not self.it.LingV then
        return
    end
    
    local Ling = npc.MaxLing - npc.LingV
    Ling = math.ceil(Ling)
    local name = self.it:GetName()
    
    if self.it.LingV > Ling then
        npc:AddLing(Ling)
        self.it:AddLing(-Ling)
        world:ShowMsgBox(name..'给'..npc.Name..'补充了'..Ling..'灵气')
    else
        Ling = self.it.LingV
        npc:AddLing(Ling)
        self.it:AddLing(-Ling)
        world:ShowMsgBox(name..'给'..npc.Name..'补充了'..Ling..'灵气')
    end
end

function tbThing:InLing(npc)
    -- 添加参数检查
    if not npc or not npc.LingV or not self.it then
        return
    end
    
    local Ling = npc.LingV / 2
    Ling = math.ceil(Ling)
    
    -- 确保有足够的灵气可以转移
    if Ling > 0 then
        npc:AddLing(-Ling)
        self.it:AddLing(Ling)
        local name = self.it:GetName()
        world:ShowMsgBox(npc.Name..'给'..name..'补充了'..Ling..'灵气')
    end
end
