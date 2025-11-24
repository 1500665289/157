local tbThing = GameMain:GetMod("ThingHelper"):GetThing("KongTiao_Building");

function tbThing:OnInit()
    if self.Time == nil then
        self.Time = 0;
    end
    if self.WenDu == nil then
        self.WenDu = 20;
    end
end

function tbThing:OnStep(dt)
    local it = self.it;
    if it.BuildingState == CS.XiaWorld.g_emBuildingState.Working then
        self.Time = self.Time + dt;
        if (it.AtRoom ~= nil) then
            if (self.Time >= 2) then
                xlua.private_accessible(CS.XiaWorld.AreaRoom);
                local MapWenDu = Map:GetGlobleTemperature();
                local WuWenDu = it.AtRoom.m_fTemperatureWall;
                print(WuWenDu);
                local WenDuCha = self.WenDu - MapWenDu - WuWenDu;
                local setWenDu = WenDuCha * it.AtRoom.m_lisGrids.Count / 25;
                print(setWenDu);
                it.def.Heat.RoomValue = setWenDu;
                self.Time = 0;
            end
        end
    end
end

function tbThing:OnPutDown()
    self.it:RemoveBtnData("设定", nil, "bind.luaclass:GetTable():UseKongTiao()", "调节空调温度", nil);
    self.it:AddBtnData("设定", nil, "bind.luaclass:GetTable():UseKongTiao()", "调节空调温度", nil);
end

function tbThing:UseKongTiao()
    local xWindow = GameMain:GetMod("Windows"):GetWindow("KongTiaoWindow");
    xWindow:Hide();
    xWindow:SetUpData(self);
    xWindow:Show();
end

function tbThing:setWenDu(WenDu)
    self.WenDu = WenDu;
end
