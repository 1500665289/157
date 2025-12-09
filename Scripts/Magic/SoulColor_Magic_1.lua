-- 炼制灵石 v1.1
local tbTable = GameMain:GetMod("MagicHelper")
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1")

-- 常量定义
local GENERATION_INTERVAL = 150     -- 灵石生成间隔帧数
local MIN_LING_REQUIRED = 0         -- 最小灵气需求

-- 内部状态枚举
local MagicState = {
    IDLE = 0,
    GENERATING = 1,
    FINISHED = 2,
    FAILED = 3
}

function tbMagic:Init()
    self.Count = 0
    self.state = MagicState.IDLE
    self.lastGenerationTime = 0
end

-- 神通是否可用
function tbMagic:EnableCheck(npc)
    if not npc then
        return false, "目标不存在"
    end
    
    if npc.LingV < (self.magic.CostLing or 0) then
        return false, "灵气不足"
    end
    
    return true
end

-- 目标合法检测
function tbMagic:TargetCheck(key, target)
    if not key or not target then
        return false, "无效目标"
    end
    
    -- 可以根据需要添加更多目标检查逻辑
    -- 例如：检查目标是否为特定类型的地块或物体
    
    return true
end

-- 开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
    self.Count = 0
    self.state = MagicState.GENERATING
    self.lastGenerationTime = 0
    
    local cost = self.magic.CostLing or 0
    if cost > 0 then
        self.bind:AddLing(cost)
    end
    
    -- 记录施法开始日志
    self:LogAction("开始炼制灵石", {
        cost = cost,
        position = self.bind.Key,
        character = self.bind.Name
    })
    
    return true
end

-- 神通施展过程中
function tbMagic:MagicStep(dt, duration)
    if self.state ~= MagicState.GENERATING then
        return self.state == MagicState.FINISHED and 1 or -1
    end
    
    self.Count = self.Count + 1
    
    -- 检查灵气是否足够
    local cost = self.magic.CostLing or 0
    if self.bind.LingV < cost then
        self.state = MagicState.FINISHED
        self:LogAction("灵气不足，停止炼制", {
            currentLing = self.bind.LingV,
            requiredLing = cost
        })
        return 1
    end
    
    -- 检查是否到达生成时间
    if self.Count >= GENERATION_INTERVAL then
        local success = self:GenerateLingStone()
        if success then
            -- 扣除灵气
            self.bind:AddLing(-cost)
            self.lastGenerationTime = self.Count
            
            -- 检查是否还能继续
            if self.bind.LingV < cost then
                self.state = MagicState.FINISHED
                self:LogAction("灵气耗尽，炼制结束", {
                    totalGenerated = self:GetTotalGenerated(),
                    remainingLing = self.bind.LingV
                })
                return 1
            end
        else
            self.state = MagicState.FAILED
            self:LogAction("灵石生成失败", { position = self.bind.Key })
            return -1
        end
        
        self.Count = 0  -- 重置计数器继续下一轮
    end
    
    -- 更新施法进度显示
    local progress = math.min(self.Count / GENERATION_INTERVAL, 1.0)
    self:SetProgress(progress)
    
    return 0
end

-- 灵石生成逻辑
function tbMagic:GenerateLingStone()
    local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone")
    if not item then
        return false
    end
    
    item.FSItemState = -1
    
    -- 确保在地图范围内生成
    local position = self.bind.Key
    if not position then
        position = self.bind.Position or 0
    end
    
    local success = self.bind.map:DropItem(
        item,
        position,
        true,    -- bVisible 可见
        true,    -- bCary    可携带
        false,   -- bNoxSelf 无自我
        false,   -- bNeedClick 需要点击
        0,       -- nWait 等待时间
        false    -- bScatter 是否分散
    )
    
    if success then
        self:LogAction("灵石生成成功", {
            itemId = item.ID,
            position = position,
            quality = item.Quality
        })
    end
    
    return success
end

-- 施展完成/失败
function tbMagic:MagicLeave(success)
    self.state = MagicState.IDLE
    
    if success then
        self:LogAction("神通正常结束", {
            totalDuration = self.Count,
            totalGenerated = self:GetTotalGenerated()
        })
    else
        self:LogAction("神通异常结束", {
            reason = "未知错误",
            currentState = self.state
        })
    end
    
    -- 清理临时数据
    self.Count = 0
    self.lastGenerationTime = 0
end

-- 辅助函数：记录日志
function tbMagic:LogAction(action, data)
    if not action then return end
    
    local logMessage = string.format("[炼制灵石] %s", action)
    if data then
        local dataStr = {}
        for k, v in pairs(data) do
            table.insert(dataStr, string.format("%s=%s", k, tostring(v)))
        end
        logMessage = logMessage .. " [" .. table.concat(dataStr, ", ") .. "]"
    end
    
    print(logMessage)
    
    -- 如果需要，可以添加更复杂的日志记录逻辑
    -- 例如：写入文件或发送到服务器
end

-- 辅助函数：获取总生成数量
function tbMagic:GetTotalGenerated()
    if self.lastGenerationTime == 0 then
        return 0
    end
    return math.floor(self.Count / GENERATION_INTERVAL)
end

-- 辅助函数：设置施法进度
function tbMagic:SetProgress(progress)
    -- 这里可以调用游戏提供的进度显示接口
    if self.bind and self.bind.SetMagicProgress then
        self.bind:SetMagicProgress(progress)
    end
    
    -- 更新UI显示
    if self.magic and self.magic.OnProgressUpdate then
        self.magic:OnProgressUpdate(progress)
    end
end

-- 预检查函数：施法前验证
function tbMagic:PreCheck()
    if not self.bind or not self.bind.map then
        return false, "角色或地图无效"
    end
    
    if not self.magic or not self.magic.CostLing then
        return false, "神通配置错误"
    end
    
    return true
end
