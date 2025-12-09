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

--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function tbMagic:TargetCheck(key, t)
	return true
end

--开始施展神通
function tbMagic:MagicEnter(IDs, IsThing)
	self.Count = 0;
	self.bind:AddLing(-self.magic.CostLing);
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
function tbMagic:MagicStep(dt,duration)
	--self:SetProgress(durationf.magic.Param1);--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	self.Count = self.Count + 1;
	if self.Count == 150 then
		local item = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_LingStone");--读取物品
		item.FSItemState = -1;--镇物状态0未知 -1无 1有未鉴定 2有已鉴定
		self.bind.map:DropItem(item,self.bind.Key,true,true,false,false,0,false);--地图掉落物品方法：物品、地点、是否可见、是否携带、没有自我、需要点击、等待、分散。
		print(self.bind.LingV);
		print(self.bind);
		self.bind:AddLing(-self.magic.CostLing);
		if self.bind.LingV < self.magic.CostLing then
			return 1;
		end
		self.Count = 0;
	end
	return 0;
end

--施展完成/失败 success是否成功
function tbMagic:MagicLeave(success)
end
