local tbThing = GameMain:GetMod("ThingHelper"):GetThing("MoFaZhen_Building");

--点击建筑
function tbThing:OnPutDown()

  self.it:RemoveBtnData("输出", nil, "bind.luaclass:GetTable():SelectNpcOut()", "使用魔法阵灵气补充自身灵气", nil);
  self.it:AddBtnData("输出", nil, "bind.luaclass:GetTable():SelectNpcOut()", "使用魔法阵灵气补充自身灵气", nil);

  self.it:RemoveBtnData("输入", nil, "bind.luaclass:GetTable():SelectNpcIn()", "输出自身二分之一灵气进入魔法阵", nil);
  self.it:AddBtnData("输入", nil, "bind.luaclass:GetTable():SelectNpcIn()", "输出自身二分之一灵气进入魔法阵", nil);

end

--使用、查询内门NPC
function tbThing:SelectNpcOut()
  CS.Wnd_SelectNpc.Instance:Select(
		WorldLua:GetSelectNpcCallback(function(rs)
			if (rs == nil or rs.Count == 0) then
				return
			end
			self:OutLing(ThingMgr:FindThingByID(rs[0]))
		end), 
	g_emNpcRank.Disciple, 1, 1, nil, nil, "选择角色");
end

function tbThing:SelectNpcIn()
  CS.Wnd_SelectNpc.Instance:Select(
		WorldLua:GetSelectNpcCallback(function(rs)
			if (rs == nil or rs.Count == 0) then
				return
			end
			self:InLing(ThingMgr:FindThingByID(rs[0]))
		end), 
	g_emNpcRank.Disciple, 1, 1, nil, nil, "选择角色");
end

function tbThing:OutLing(npc)
	local Ling = npc.MaxLing - npc.LingV;
	Ling = math.ceil(Ling)
	local name = self.it:GetName()
	if(self.it.LingV > Ling) then
		npc:AddLing(Ling);
		self.it:AddLing(-Ling);
		world:ShowMsgBox(name..'给'..npc.Name..'补充了'..Ling..'灵气');
		return;
	end
	Ling = self.it.LingV;
	npc:AddLing(Ling);
	self.it:AddLing(-Ling);
	world:ShowMsgBox(name..'给'..npc.Name..'补充了'..Ling..'灵气');
end

function tbThing:InLing(npc)
	local Ling = npc.LingV / 2;
	Ling = math.ceil(Ling);
	npc:AddLing(-Ling);
	self.it:AddLing(Ling);
	local name = self.it:GetName()
	world:ShowMsgBox(npc.Name..'给'..name..'补充了'..Ling..'灵气');
end