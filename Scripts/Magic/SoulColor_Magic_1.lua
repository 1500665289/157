--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper");--获取神通模块 这里不要动
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1");--创建一个新的神通class

function tbMagic:Init()
    self.Count = 0;
    self.lastGenerateTime = 0;  -- 记录上次生成灵石的时间
end

--神通是否可用
function tbMagic:EnableCheck(npc)
    -- 检查NPC是否有足够的灵石
    if npc and npc.LingV >= self.magic.CostLing then
        return true;
    end
    return false;
end

--目标合法检测
function tbMagic:TargetCheck(key, t)
    return true
end

--开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
    self.Count = 0;
    self.lastGenerateTime = 0;
    
    print(string.format("开始持续炼制灵石，每150帧消耗%d灵石生成一个灵石", self.magic.CostLing));
    print(string.format("当前灵气值: %d", self.bind.LingV));
    print(string.format("施法者位置: %s", tostring(self.bind.Key)));
end

--神通施展过程中
function tbMagic:MagicStep(dt, duration)
    self.Count = self.Count + 1;
    
    -- 设置进度显示（基于帧数）
    self:SetProgress((self.Count % 150) / 150);
    
    -- 每150帧生成一个灵石
    if self.Count >= 150 then
        -- 检查是否有足够的灵气
        if self.bind.LingV >= self.magic.CostLing then
            -- 1. 先扣除灵气
            self.bind:AddLing(-self.magic.CostLing);
            
            -- 2. 生成灵石物品
            local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone");
            if item then
                item.FSItemState = -1;  -- 镇物状态
                
                -- 在地图上掉落物品到NPC脚下
                if self.bind and self.bind.map then
                    -- 获取NPC的当前位置
                    local npcPos = self.bind.Pos;
                    
                    -- 使用NPC当前位置作为掉落位置
                    self.bind.map:DropItem(
                        item,           -- 物品
                        npcPos,         -- 地点：NPC的当前位置
                        true,           -- 是否可见
                        true,           -- 是否携带
                        false,          -- 没有自我
                        false,          -- 需要点击
                        0,              -- 等待
                        false           -- 分散
                    );
                    
                    print(string.format("成功在脚下生成灵石！位置: (%.1f, %.1f), 消耗灵气: %d, 剩余灵气: %d", 
                        npcPos.x, npcPos.y, self.magic.CostLing, self.bind.LingV));
                end
            end
            
            -- 重置计数器
            self.Count = 0;
            self.lastGenerateTime = self.bind.Age;  -- 记录生成时间
            
        else
            -- 灵气不足，结束神通
            print(string.format("灵气不足，结束炼制。需要: %d, 当前: %d", 
                self.magic.CostLing, self.bind.LingV));
            return 1;  -- 结束神通
        end
    end
    
    return 0;  -- 继续
end

--施展完成/失败
function tbMagic:MagicLeave(success)
    if success then
        print("炼制灵石正常结束");
    else
        print("炼制灵石被中断");
    end
    
    -- 重置状态
    self.Count = 0;
    self.lastGenerateTime = 0;
end
