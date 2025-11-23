local Windows = GameMain:GetMod("Windows");--先注册一个新的MOD模块
local tbWindow = Windows:CreateWindow("MoFaZhenWindow");

function tbWindow:OnInit()
	self.window.contentPane =  UIPackage.CreateObject("SoulColor", "MoFaZhenWindow");--载入UI包里的窗口
	self.window.closeButton = self:GetChild("frame"):GetChild("n5");
	self.window:Center();
	self.bnt1 = self:GetChild("bnt_1");
	self.bnt1.text = '幽淬物品';
	self.bnt1.onClick:Add(OnClick01);
	self.bnt1.data = self;
	self.bnt2 = self:GetChild("bnt_2");
	self.bnt2.text = '天劫法宝';
	self.bnt2.onClick:Add(OnClick02);
	self.bnt2.data = self;
	self.bnt3 = self:GetChild("bnt_3");
	self.bnt3.onClick:Add(OnClick03);
	self.bnt3.text = '提升品质';
	self.bnt3.data = self;
	self.bnt4 = self:GetChild("bnt_4");
	self.bnt4.text = '备用';
	self.bnt4.onClick:Add(OnClick04);
	self.bnt4.data = self;
	self.list = self:GetChild("list");
end

function tbWindow:SetUpData(npc,equip,storage)
	self.npc = npc;
	self.equip = equip;
	self.storage = storage;
end

function tbWindow:OnShowUpdate()
	self.Item = nil;
	self:GetChild("frame").title = self.npc:GetName();
	self:Refresh();
	local itemList = self.equip:GetEquipAll();
	--local item = self.equip:GetEquip(CS.XiaWorld.g_emEquipType.Tool1);
	self.list:RemoveChildrenToPool();--删除list内容
	for i, item in pairs(itemList) do
		--local itemx = ThingMgr:FindThingByID(itemList[i].ID);
		local items = self.list:AddItemFromPool();
		if item.IsFaBao then
			items.icon = item.Fabao.OitemDef.TexPath;
		else
			items.icon = item.def.TexPath;
		end
		print(item.def.TexPath);
		items.title = "[size=8]"..item:GetName().."[/size]";
		if item.IsFaBao then
			items.tooltips = "法宝";
		else
			items.tooltips = "[size=12]"..item:GetDesc().."[/size]";
		end
		items.data = {self,item};
	end
	self.list.onClickItem:Add(ClickSelectItem);
end

function ClickSelectItem(context)
	local self = context.data.data[1];
	local item = context.data.data[2];
	local text = item:GetName();
	self.Item = item;
	self.labe3.text = "当前物品：：[color=#FF0000]"..item:GetName().."[/color]";
	self:Refresh();
end

function OnClick01(context)
	local s = context.sender.data;
	if s.Item == nil then;
		world:ShowMsgBox("没有选中物品");
		s:Refresh();
		return;
	end
	if s.Item ~= nil then
		local rate = s.Item.Rate;
		if 12 ~= rate then
			local XiaoHao = (rate + 1) * 10000;
			local Ling = s.npc.LingV;
			local JZLing = s.storage.LingV;
			Ling = math.ceil(Ling);
			JZLing = math.ceil(JZLing);
			if Ling + JZLing >= XiaoHao then
				if Ling >= XiaoHao then
					s.npc:AddLing(-XiaoHao);
				else
					s.npc:AddLing(-Ling);
					XiaoHao = XiaoHao - Ling;
					s.storage:AddLing(-XiaoHao);
				end
				s.Item:SoulCrystalYouPowerUp(0,1,1);
				world:ShowMsgBox(s.Item:GetName().."强化完成");
				s:Refresh();
			else
				world:ShowMsgBox("人物灵气+建筑灵气不足消耗灵气"..XiaoHao);
				s:Refresh();
			end
		else
			world:ShowMsgBox(s.Item:GetName().."已达等级上限");
			s:Refresh();
		end
	end
end

function OnClick02(context)
	local s = context.sender.data;
	if s.Item == nil then;
		world:ShowMsgBox("没有选中物品");
		s:Refresh();
		return;
	end
	if s.Item.IsFaBao then
		local GodC = s.Item.Fabao.GodCount;
		if 36 ~= GodC then
			local XiaoHao = (GodC + 1) * 10000;
			local Ling = s.npc.LingV;
			local JZLing = s.storage.LingV;
			Ling = math.ceil(Ling);
			JZLing = math.ceil(JZLing);
			if Ling + JZLing >= XiaoHao then
				if Ling >= XiaoHao then
					s.npc:AddLing(-XiaoHao);
				else
					s.npc:AddLing(-Ling);
					XiaoHao = XiaoHao - Ling;
					s.storage:AddLing(-XiaoHao);
				end
				s.Item.Fabao:AddGodCount(1);
				world:ShowMsgBox(s.Item:GetName().."强化完成");
				s:Refresh();
			else
				world:ShowMsgBox("人物灵气+建筑灵气不足消耗灵气"..XiaoHao);
				s:Refresh();
			end
		else
			world:ShowMsgBox(s.Item:GetName().."已达等级上限");
			s:Refresh();
		end
	else
		world:ShowMsgBox("选中物品不是法宝");
		s:Refresh();
		return;
	end
end

function OnClick03(context)
	local s = context.sender.data;
	if s.Item == nil then;
		world:ShowMsgBox("没有选中物品");
		s:Refresh();
		return;
	end
	if s.Item ~= nil then
		s.Item:ChangeBeauty(15);
		s.Item:SetQuality(1);
		world:ShowMsgBox(s.Item:GetName().."提升完成");
		s:Refresh();
	end
end

function OnClick04(context)
	local npc = context.sender.data.npc;
end

function tbWindow:OnShown()
end

function tbWindow:OnUpdate(dt)

end

function tbWindow:OnHide()
end

function tbWindow:Refresh()
	self.label = self:GetChild("label_1");
	local Ling = self.npc.LingV;
	Ling = math.ceil(Ling);
	self.label.text = "人物灵气：[color=#FF0000]"..Ling.."[/color]";
	local JZLing = self.storage.LingV;
	JZLing = math.ceil(JZLing);
	self.labe2 = self:GetChild("label_2");
	self.labe2.text = "建筑灵气：[color=#FF0000]"..JZLing.."[/color]";
	self.labe3 = self:GetChild("label_3");
	if self.Item == nil then
		self.labe3.text = "当前物品：";
	else
		self.labe3.text = "当前物品：[color=#FF0000]"..self.Item:GetName().."[/color]";
	end
	self.labe4 = self:GetChild("label_4");
	self.labe4.text = "消耗灵气：[color=#FF0000]目标级×一万灵气[/color]";
end