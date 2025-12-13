--炼制灵石
local tbTable = GameMain:GetMod("MagicHelper");--获取神通模块 这里不要动
local tbMagic = tbTable:GetMagic("SoulColor_Magic_1");--创建一个新的神通class

local Count;

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
	self.bind:AddLing(-self.magic.CostLing);
end

--神通施展过程中
function tbMagic:MagicStep(dt,duration)
	self.Count = self.Count + 1;
	if self.Count == 5 then
		-- 查找角色周围已存在的灵石
		local existingLingStone = self:FindNearbyLingStone();
		
		if existingLingStone then
			-- 找到已存在的灵石，增加其数量
			existingLingStone.Number = existingLingStone.Number + 1;
			print("灵石数量已堆叠，当前数量：" .. existingLingStone.Number);
		else
			-- 没有找到已存在的灵石，掉落新的灵石
			local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone");
			item.FSItemState = -1;
			
			-- 掉落灵石到角色位置
			self.bind.map:DropItem(item, self.bind.Key, true, true, false, false, 0, false);
			print("掉落新的灵石");
		end
		
		print("当前灵气值：" .. self.bind.LingV);
		self.bind:AddLing(-self.magic.CostLing);
		
		-- 灵气不足时结束神通
		if self.bind.LingV < self.magic.CostLing then
			return 1;
		end
		
		self.Count = 0;
	end
	return 0;
end

--施展完成/失败
function tbMagic:MagicLeave(success)
	-- 清理工作
	self.Count = nil;
end

-- 查找角色周围已存在的灵石
function tbMagic:FindNearbyLingStone()
	local npc = self.bind;
	if not npc or not npc.map then
		return nil;
	end
	
	local cellKey = npc.Key; -- 角色所在格子
	local map = npc.map;
	local range = 1; -- 搜索范围（格子数）
	
	-- 获取角色当前位置
	local centerCell = map:GetCell(cellKey);
	if not centerCell then
		return nil;
	end
	
	-- 搜索周围格子
	local cells = map:GetRoundGrids(centerCell.x, centerCell.y, range);
	
	for _, cell in pairs(cells) do
		-- 检查格子中的物品
		local things = map:GetThings(cell.Key);
		if things and things.Count > 0 then
			for i = 0, things.Count - 1 do
				local thing = things[i];
				-- 检查是否是灵石
				if thing and thing.Def.Name == "Item_LingStone" then
					-- 确保灵石在地上（不是被携带或装备）
					if thing.Pos and not thing.EquipCharacter and not thing.CarryCharacter then
						return thing;
					end
				end
			end
		end
	end
	
	return nil;
end