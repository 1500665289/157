--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper")  --获取神通模块
local tbMagic = tbTable:GetMagic("LingStoneMake")  --修改为XML中的魔法名称

local frameCount  -- 帧计数器
local totalFrames  -- 总帧数

function tbMagic:Init()
    -- 初始化代码
end

--神通是否可用
function tbMagic:EnableCheck(npc)
    -- 检查是否有足够灵力
    if npc.LingV >= 5000 then
        return true
    end
    return false
end

--目标合法检测
function tbMagic:TargetCheck(key, t)
    return true
end

--开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
    frameCount = 0
    -- XML中Param1=2，表示2单位时间
    -- 假设1单位时间=10帧
    totalFrames = 2 * 10
end

--神通施展过程中
function tbMagic:MagicStep(dt, duration)
    frameCount = frameCount + 1
    
    -- 更新进度条显示
    self:SetProgress(frameCount / totalFrames)
    
    if frameCount >= totalFrames then
        -- 施法完成，再次检查灵力
        if self.bind.LingV >= 5000 then
            -- 生成灵石
            local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone")
            item.FSItemState = -1
            
            -- 在地图上掉落物品
            self.bind.map:DropItem(item, self.bind.Key, true, true, false, false, 0, false)
            
            -- 消耗灵力
            self.bind:AddLing(-5000)
            
            print(string.format("%s 炼制灵石成功，消耗5000灵力，剩余%.0f灵力", 
                self.bind.Name, self.bind.LingV))
            
            return 1  -- 成功并结束
        else
            print(string.format("%s 灵力不足，炼制灵石失败", self.bind.Name))
            return -1  -- 失败并结束
        end
    end
    
    return 0  -- 继续施法
end

--施展完成/失败
function tbMagic:MagicLeave(success)
    frameCount = 0
    if success then
        print("炼制灵石成功完成")
    else
        print("炼制灵石被中断")
    end
end
