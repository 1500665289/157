--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper");--获取神通模块 这里不要动
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1");--创建一个新的神通class

local Count;
local targetKey; -- 存储施法者脚下的位置

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function tbMagic:Init()
end

--神通是否可用
function tbMagic:EnableCheck(npc)
	return true;
end

--目标合法检测
function tbMagic:TargetCheck(key, t)
	return true
end

--开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
	self.Count = 0;
	self.bind:AddLing(self.magic.CostLing);
	-- 记录施法者当前位置
	targetKey = self.bind.Key;
end

--神通施展过程中
function tbMagic:MagicStep(dt, duration)
	self.Count = self.Count + 1;
	-- 减少生成时间，从150减少到30（约5倍速度）
	if self.Count >= 30 then
		-- 获取施法者脚下的所有物品
		local items = self.bind.map:GetItemsByKey(targetKey);
		local existingLingStone = nil;
		
		-- 查找是否已经有灵石
		if items and items.Count > 0 then
			for i = 0, items.Count - 1 do
				local item = items[i];
				if item and item.Def.Name == "Item_LingStone" then
					existingLingStone = item;
					break;
				end
			end
		end
		
		if existingLingStone then
			-- 如果有灵石，增加堆叠数量
			if existingLingStone.MaxNum > existingLingStone.Num then
				existingLingStone:AddNum(1);
			else
				-- 如果堆叠已满，创建新的灵石
				local newItem = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone");
				newItem.FSItemState = -1;
				self.bind.map:DropItem(newItem, targetKey, true, true, false, false, 0, false);
			end
		else
			-- 如果没有灵石，创建新的灵石
			local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone");
			item.FSItemState = -1;
			self.bind.map:DropItem(item, targetKey, true, true, false, false, 0, false);
		end
		
		-- 扣除灵力
		self.bind:AddLing(-self.magic.CostLing);
		
		-- 检查灵力是否足够继续
		if self.bind.LingV < self.magic.CostLing then
			return 1; -- 灵力不足，结束神通
		end
		
		self.Count = 0; -- 重置计数器
	end
	return 0;
end

--施展完成/失败
function tbMagic:MagicLeave(success)
	-- 清理变量
	targetKey = nil;
end
