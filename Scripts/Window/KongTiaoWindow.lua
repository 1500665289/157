local Windows = GameMain:GetMod("Windows");--先注册一个新的MOD模块
local tbWindow = Windows:CreateWindow("KongTiaoWindow");

function tbWindow:OnInit()
	self.window.contentPane =  UIPackage.CreateObject("SoulColor", "KongTiaoWindow");--载入UI包里的窗口
	self.window.closeButton = self:GetChild("frame"):GetChild("n5");
	self.window:Center();
	self.bnt1 = self:GetChild("bnt_1");
	self.bnt1.onClick:Add(OnClick11);
	self.bnt1.data = self;
	self.bnt2 = self:GetChild("bnt_2");
	self.bnt2.onClick:Add(OnClick12);
	self.bnt2.data = self;
	self.bnt3 = self:GetChild("bnt_3");
	self.bnt3.onClick:Add(OnClick13);
	self.bnt3.data = self;
	self.bnt4 = self:GetChild("bnt_4");
	self.bnt4.onClick:Add(OnClick14);
	self.bnt4.data = self;
	self.bnt5 = self:GetChild("bnt_5");
	self.bnt5.onClick:Add(OnClick15);
	self.bnt5.data = self;
	self.bnt6 = self:GetChild("bnt_6");
	self.bnt6.onClick:Add(OnClick16);
	self.bnt6.data = self;
	self.label_1 = self:GetChild("label_1");
	self:GetChild("frame").title = self.KongTiao.it:GetName();
	self:reWenDu();
end

function tbWindow:SetUpData(KongTiao)
	self.KongTiao = KongTiao;
	self.WenDu = KongTiao.WenDu;
end

function tbWindow:OnShowUpdate()
	self:GetChild("frame").title = self.KongTiao.it:GetName();
	self:reWenDu();
end

function OnClick11(context)
	local self = context.sender.data;
	self.WenDu = self.WenDu - 100;
	self:reWenDu();
end

function OnClick12(context)
	local self = context.sender.data;
	self.WenDu = self.WenDu - 10;
	self:reWenDu();
end

function OnClick13(context)
	local self = context.sender.data;
	self.WenDu = self.WenDu - 1;
	self:reWenDu();
end

function OnClick14(context)
	local self = context.sender.data;
	self.WenDu = self.WenDu + 1;
	self:reWenDu();
end

function OnClick15(context)
	local self = context.sender.data;
	self.WenDu = self.WenDu + 10;
	self:reWenDu();
end

function OnClick16(context)
	local self = context.sender.data;
	self.WenDu = self.WenDu + 100;
	self:reWenDu();
end

function tbWindow:reWenDu()
	self.label_1.text = self.WenDu;
	self.KongTiao:setWenDu(self.WenDu);
end

function tbWindow:OnShown()

end

function tbWindow:OnUpdate(dt)

end

function tbWindow:OnHide()

end