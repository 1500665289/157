--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper");--获取神通模块 这里不要动
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1");--创建一个新的神通class

local Count;
local item; -- 将item提升为局部变量，方便多个函数访问

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function tbMagic:Init()
    self.Count = 0;
    self.item = nil;
end

--神通是否可用
function tbMagic:EnableCheck(npc)
    -- 检查是否有足够的灵气
    if npc.LingV < self.magic.CostLing then
        return false;
    end
    return true;
end

--目标合法检测
function tbMagic:TargetCheck(key, t)
    return true
end

--开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
    self.Count = 0;
    self.item = nil;
    self.bind:AddLing(-self.magic.CostLing);
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
function tbMagic:MagicStep(dt, duration)
    self.Count = self.Count + 1;
    
    -- 每150帧（约5秒，假设30帧/秒）炼制一个灵石
    if self.Count >= 150 then
        -- 再次检查灵气是否足够
        if self.bind.LingV < 1 then
            return 1; -- 灵气不足，结束神通
        end
        
        -- 创建灵石
        self.item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone");
        self.item.FSItemState = -1; -- 镇物状态0未知 -1无 1有未鉴定 2有已鉴定
        
        -- 获取NPC的位置，并在前方掉落物品
        local dropPosition = self.bind.Key;
        
        -- 可以稍微调整掉落位置，避免卡在NPC身上
        -- 随机偏移一点位置
        local offsetX = math.random(-1, 1);
        local offsetY = math.random(-1, 1);
        dropPosition.x = dropPosition.x + offsetX;
        dropPosition.y = dropPosition.y + offsetY;
        
        -- 在地图上掉落物品
        self.bind.map:DropItem(
            self.item,        -- 物品
            dropPosition,     -- 位置
            true,            -- 是否可见
            true,            -- 是否可拾取
            false,           -- 没有自我
            false,           -- 需要点击
            0,               -- 等待时间
            false            -- 是否分散
        );
        
        -- 每次炼制消耗少量灵气
        self.bind:AddLing(-1);
        
        print(string.format("炼制灵石成功！NPC灵气剩余: %d", self.bind.LingV));
        
        -- 重置计数器
        self.Count = 0;
        
        -- 如果灵气耗尽，结束神通
        if self.bind.LingV < 1 then
            return 1;
        end
    end
    
    -- 设置进度显示（可选）
    local progress = self.Count / 150;
    self:SetProgress(progress);
    
    return 0; -- 继续执行
end

--施展完成/失败
function tbMagic:MagicLeave(success)
    self.Count = 0;
    self.item = nil;
    
    if success then
        print("神通-炼制灵石 施展完成");
    else
        print("神通-炼制灵石 施展失败或中断");
    end
end
