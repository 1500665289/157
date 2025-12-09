--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper");--获取神通模块 这里不要动
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1");--创建一个新的神通class

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function tbMagic:Init()
    self.Count = 0;  -- 初始化计数器
end

--神通是否可用
function tbMagic:EnableCheck(npc)
    if not npc then
        return false
    end
    return true;
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function tbMagic:TargetCheck(key, t)
    return true
end

--开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
    self.Count = 0;
    -- 修复：应该是消耗灵力，不是增加灵力
    self.bind:AddLing(-self.magic.CostLing);  -- 修复：添加负号
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
function tbMagic:MagicStep(dt,duration)
    -- 修复：设置施展进度（取消注释并修正语法）
    local castTime = self.magic.Param1 or 3  -- 默认10秒
    local progress = math.min(duration / castTime, 1.0)
    self:SetProgress(progress);  -- 设置施展进度 主要用于UI显示
    
    self.Count = self.Count + 1;
    if self.Count == 150 then
        -- 安全检查
        if not self.bind or not self.bind.map then
            return -1  -- 施法者或地图不存在，失败结束
        end
        
        -- 安全生成物品
        local success, item = pcall(function()
            return CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone")
        end)
        
        if not success or not item then
            print("错误：生成灵石失败")
            return -1
        end
        
        item.FSItemState = -1;--镇物状态0未知 -1无 1有未鉴定 2有已鉴定
        
        -- 安全掉落物品
        local dropSuccess, result = pcall(function()
            return self.bind.map:DropItem(item,self.bind.Key,true,true,false,false,0,false)
        end)
        
        if not dropSuccess then
            print("错误：掉落物品失败 - " .. tostring(result))
            return -1
        end
        
        print("当前灵力: " .. tostring(self.bind.LingV));
        print("施法者: " .. tostring(self.bind.Name));
        
        -- 检查灵力是否充足继续
        if self.bind.LingV < self.magic.CostLing then
            return 1;  -- 灵力不足，成功结束
        end
        
        self.Count = 0;  -- 重置计数器，继续炼制
    end
    
    -- 检查施法时间是否结束
    if duration >= (self.magic.Param1 or 10) then
        return 1;  -- 施法时间结束，成功完成
    end
    
    return 0;
end

--施展完成/失败 success是否成功
function tbMagic:MagicLeave(success)
    if success then
        print("炼制灵石神通施展成功")
    else
        print("炼制灵石神通施展失败")
        -- 可以在这里添加失败处理逻辑
    end
end