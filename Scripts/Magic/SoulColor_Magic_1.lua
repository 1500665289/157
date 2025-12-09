--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper")
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1")

local Count
local itemGenerated = false  -- 标记灵石是否已生成

function tbMagic:Init()
    self.requiredLing = self.magic.CostLing or 1000  -- 默认消耗100灵气
    self.castTime = self.magic.Param1 or 3  -- 施法时间，单位：秒
    self.frameCount = 0
    self.totalFrames = self.castTime * 30  -- 假设30帧/秒
end

function tbMagic:EnableCheck(npc)
    -- 检查是否有足够灵气
    if npc.LingV < self.requiredLing then
        return false, "灵气不足"
    end
    return true
end

function tbMagic:TargetCheck(key, t)
    -- 可以在特定地点炼制，比如炼器室
    local room = self.bind.Room
    if room and room.RoomType == "ForgeRoom" then
        return true
    end
    return true  -- 或者返回false限制只能在炼器室
end

function tbMagic:MagicEnter(IDs, IsThing)
    self.frameCount = 0
    self.itemGenerated = false
    
    -- 立即扣除灵气
    local success = self.bind:AddLing(-self.requiredLing)
    if not success then
        return -1  -- 失败
    end
    
    print(string.format("开始炼制灵石，消耗灵气: %d", self.requiredLing))
    return 0
end

function tbMagic:MagicStep(dt, duration)
    self.frameCount = self.frameCount + 1
    
    -- 更新施法进度
    local progress = self.frameCount / self.totalFrames
    self:SetProgress(progress)
    
    -- 在施法结束时生成灵石
    if not self.itemGenerated and self.frameCount >= self.totalFrames then
        self:GenerateLingStone()
        self.itemGenerated = true
        return 1  -- 成功结束
    end
    
    -- 中途可以取消的检查
    if self.bind.HP <= 0 or self.bind.Death then
        return -1  -- 角色死亡，施法失败
    end
    
    return 0
end

function tbMagic:GenerateLingStone()
    -- 生成灵石
    local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone")
    
    -- 设置灵石属性
    item.FSItemState = -1
    
    -- 在角色所在位置生成灵石
    local success = self.bind.map:DropItem(
        item, 
        self.bind.Key,  -- 掉落位置
        true,           -- 是否可见
        true,           -- 是否可拾取
        false,          -- 没有自我
        false,          -- 需要点击
        0,              -- 等待时间
        false           -- 是否分散
    )
    
    if success then
        print("炼制成功！获得灵石")
        
        -- 可选：增加炼制技能经验
        if self.bind.SkillMgr then
            self.bind.SkillMgr:AddExp("Forge", 10)
        end
    else
        print("炼制失败：物品生成失败")
    end
    
    return success
end

function tbMagic:MagicLeave(success)
    if success then
        print("灵石炼制完成")
    else
        print("灵石炼制中断")
        
        -- 如果中断，可以返还部分灵气
        if not self.itemGenerated and self.bind then
            local refund = math.floor(self.requiredLing * 0.5)  -- 返还50%
            self.bind:AddLing(refund)
            print(string.format("炼制中断，返还灵气: %d", refund))
        end
    end
    
    -- 重置状态
    self.frameCount = 0
    self.itemGenerated = false
end

-- 可选：添加冷却时间
function tbMagic:GetCooldown()
    return self.magic.Param2 or 10  -- 参数2作为冷却时间，默认10秒
end
