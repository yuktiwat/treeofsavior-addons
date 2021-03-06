local cwMarket = {};

local log = cwAPI.util.log;
local alert = ui.SysMsg;

-- ======================================================
--	MARKET - CABINET
-- ======================================================

function cwMarket.retrieveAllType(atr) 
	local list = cwMarket.readytoget[atr];
	local max = #list;
	for i = 0, max do
		local itemID = list[i];
		if (itemID) then market.ReqGetCabinetItem(itemID); end
	end
	cwMarket.itemButton:SetEnable(0);
	cwMarket.silverButton:SetEnable(0);
	market.ReqCabinetList();
end

function cwMarket_retrieveAllSilver() 
	cwMarket.retrieveAllType('silver');
end

function cwMarket_retrieveAllItems() 
	cwMarket.retrieveAllType('items');
end


function cwMarket.createRetrieveButtons()
	local frame = ui.GetFrame('market_cabinet');
	if (not frame) then return; end
	local ctrl = frame:CreateOrGetControl('button', 'cwmarket_RETRIEVESILVER', 0, 0, 250, 50);
	ctrl:SetSkinName('test_red_button');
	ctrl:SetGravity(ui.RIGHT, ui.BOTTOM);
	ctrl:Move(0,0);
	ctrl:SetOffset(200,20);
	ctrl:SetText("{@st41b}{img Silver 24 24}{/}");
	ctrl:SetClickSound('button_click_big');
	ctrl:SetOverSound('button_over');	
	ctrl:SetEventScript(ui.LBUTTONUP,'cwMarket_retrieveAllSilver()');
	cwMarket.silverButton = ctrl;
	cwMarket.silverButton:SetEnable(0);

	local ctrl = frame:CreateOrGetControl('button', 'cwmarket_RETRIEVEITEMS', 0, 0, 170, 50);
	ctrl:SetSkinName('test_red_button');
	ctrl:SetGravity(ui.RIGHT, ui.BOTTOM);
	ctrl:Move(0,0);
	ctrl:SetOffset(455,20);
	ctrl:SetText("{@st41b}{img icon_item_small_bag 24 24}{/}");
	ctrl:SetClickSound('button_click_big');
	ctrl:SetOverSound('button_over');	
	ctrl:SetEventScript(ui.LBUTTONUP,'cwMarket_retrieveAllItems()');
	cwMarket.itemButton = ctrl;
	cwMarket.itemButton:SetEnable(0);
end

function cwMarket.cabinetItemList() 	
	local frame = ui.GetFrame('market_cabinet');
	if (not frame) then return; end

	cwMarket.createRetrieveButtons();

	cwMarket.readytoget = {};
	cwMarket.readytoget.silver = {};
	cwMarket.readytoget.items = {};

	local itemGbox = GET_CHILD(frame, "itemGbox");
	local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");

	local cnt = session.market.GetCabinetItemCount();
	local sysTime = geTime.GetServerSystemTime();	

	local counters = {};
	counters.silver = {};
	counters.silver.ready = 0;
	counters.silver.total = 0;

	counters.items = {};
	counters.items.ready = 0;
	counters.items.total = 0;

	for i = 0 , cnt - 1 do
		local cabinetItem = session.market.GetCabinetItemByIndex(i);		
		local itemID = cabinetItem:GetItemID();
		local itemObj = GetIES(cabinetItem:GetObject());

		local registerTime = cabinetItem:GetRegSysTime();
		local difSec = imcTime.GetDifSec(registerTime, sysTime);
		local count = cabinetItem.count;

		if (itemObj.ClassID == 900011) then atr = 'silver'; else atr = 'items'; end
		local res = counters[atr];

		res.total = res.total + count;
		if (0 >= difSec) then 
			res.ready = res.ready + count; 
			table.insert(cwMarket.readytoget[atr],itemID);
		end
	end

	cwMarket.silverButton:SetText("{@st41b}{img Silver 20 20} "..GetCommaedText(counters.silver.ready).." / "..GetCommaedText(counters.silver.total).."{/}");
	cwMarket.itemButton:SetText("{@st41b}{img icon_item_small_bag 24 24} "..GetCommaedText(counters.items.ready).." / "..GetCommaedText(counters.items.total).."{/}");

	if (counters.silver.ready > 0) then cwMarket.silverButton:SetEnable(1); end;
	if (counters.items.ready > 0) then cwMarket.itemButton:SetEnable(1); end;

end
-- ======================================================
--	LOADER
-- ======================================================

_G['ADDON_LOADER']['cwmarket'] = function() 
	-- checking dependences
	if (not cwAPI) then
		ui.SysMsg('[cwMarket] requires cwAPI to run.');
		return false;
	end
	-- executing onload
	if (not cwMarket.data) then cwMarket.data = {}; end

	cwMarket.createRetrieveButtons();
	cwAPI.events.on('ON_CABINET_ITEM_LIST',cwMarket.cabinetItemList,1);	
	cwMarket.cabinetItemList();

	return true;
end
