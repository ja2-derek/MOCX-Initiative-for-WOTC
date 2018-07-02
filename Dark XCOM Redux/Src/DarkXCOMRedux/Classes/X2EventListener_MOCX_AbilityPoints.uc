//---------------------------------------------------------------------------------------
//  FILE:    X2EventListener_DLC_3_AbilityPoints.uc
//  AUTHOR:  Russell Aasland
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2EventListener_MOCX_AbilityPoints extends X2EventListener_AbilityPoints;

var localized string UnitCapturedTitle;
var localized string UnitDiedTitle;
var localized string UnitCaptured;
var localized string UnitDied;

var localized string LootTitle;
var localized string Loot;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem( CreateMOCXEvacEvent() );
	Templates.AddItem( CreateMOCXKillEvent() );
	Templates.AddItem(CreateMOCXCaptureEvent());

	Templates.AddItem(CreateOverrideEC());

	Templates.AddItem(CreateGremlinDeathEvent()); //dirty but too lazy to make a new class for this

	Templates.AddItem(CreateMOCXCapturedEvent()); 

	Templates.AddItem(CreateMOCXPCSEvent());
	return Templates;
}

static function CHEventListenerTemplate CreateMOCXPCSEvent()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'MOCXPCS_UIEvent');
	//explanation: vanilla X2EvenetLIstenerTemplates do not specify deferrals, instead always being on ELD_OnStateSubmitted.
	//PCSes need to engage as soon as possible, so we use the CH highlander instead.

	Template.RegisterInStrategy = true;
	Template.AddCHEvent('OnGetPCSImage', ChangeMOCXUI, ELD_Immediate);

	return Template;
}

static function X2EventListenerTemplate CreateMOCXCapturedEvent()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'MOCXCapturedEvent');

	Template.RegisterInTactical = true;
	Template.AddEvent('UnitEvacuated', WasMOCXCaptured);

	return Template;
}

static function X2EventListenerTemplate CreateOverrideEC()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'RMMOCXOverride');
	Template.RegisterInTactical = true;
	Template.AddEvent('ExtractCorpses_AwardLoot', ShouldOverride);

	return Template;
}

static protected function EventListenerReturn ChangeMOCXUI(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local X2AbilityTemplate AbilityTemplate;
	local XComLWTuple Tuple;
	local XComGameState_Item ItemState;
	local X2EquipmentTemplate Template;

	Tuple = XComLwTuple(EventData);
	// bad data somewhere
	if (Tuple == none)
		return ELR_NoInterrupt;

	if(Tuple.Id == 'GetPCSImageTuple')	
	{
		ItemState = XComGameState_Item(Tuple.Data[0].o);

		if(ItemState == none)
			return ELR_NoInterrupt;

		Template = X2EquipmentTemplate(ItemState.GetMyTemplate());
		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(Template.Abilities[0]);

		if(AbilityTemplate == none)
			return ELR_NoInterrupt;

		Tuple.Data[1].s = AbilityTemplate.IconImage; //if we make it this far, we got a valid template, give it the image string
	}

	return ELR_NoInterrupt;
}


static protected function EventListenerReturn ShouldOverride(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local XComLWTuple Tuple;
	local XComGameState_HeadquartersDarkXCOM DarkXComHQ;

	Tuple = XComLwTuple(EventData);
	KilledUnit = XComGameState_Unit(EventSource);
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(`XCOMHistory.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	BattleData = XComGameState_BattleData( `XCOMHISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	// bad data somewhere
	if ((BattleData == none) || (KilledUnit == none) || (Tuple == none) || (DarkXComHQ.Squad.Length == 0))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier')
		return ELR_NoInterrupt;

	if(KilledUnit.IsAlive() && KilledUnit.bBodyRecovered)
	{
		if(Tuple.Id == 'ExtractCorpses_AwardLoot')	
			Tuple.Data[0].b = false;  //we'll handle this unit ourselves
			return ELR_NoInterrupt;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn WasMOCXCaptured(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local int i, LostHP;
	local XComGameState_Unit EnemyUnit, CurrentDarkUnit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCOM DarkXComHQ;
	local XComPresentationLayer Presentation;
	local XGParamTag kTag;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	KilledUnit = XComGameState_Unit(EventSource);
	BattleData = XComGameState_BattleData(HISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	LostHP = 0;
	// bad data somewhere
	if ((BattleData == none) || (KilledUnit == none) || (DarkXComHQ.Squad.Length == 0))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier')
		return ELR_NoInterrupt;

	if(KilledUnit.GetMyTemplateName() == 'DarkRookie' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M2' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M3')
	{
		Presentation = `PRES;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Owner Unit Died");
		GiveLootToXCOM(NewGameState, KilledUnit);
		`GAMERULES.SubmitGameState(NewGameState);


		kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		kTag.StrValue0 = class'UnitDarkXComUtils'.static.GetFullName(KilledUnit);

		Presentation.NotifyBanner(default.UnitDiedTitle, "img:///UILibrary_XPACK_Common.WorldMessage", KilledUnit.GetName(eNameType_Full), `XEXPAND.ExpandString(default.UnitDied),  eUIState_Bad);

		`SOUNDMGR.PlayPersistentSoundEvent("UI_Blade_Negative");
		return ELR_NoInterrupt;
	}

	if(KilledUnit.bBodyRecovered && KilledUnit.IsAlive()) //they were captured, so we can check if XCOM won the capture roll
	{

			for(i = 0; i < DarkXComHQ.Squad.Length; i++)
			{
				CurrentDarkUnit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));

				`log("Dark XCOM: Checking unit for possible capture - " $ class'UnitDarkXComUtils'.static.GetFullName(CurrentDarkUnit), ,'DarkXCom');

				InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(CurrentDarkUnit);

				if(InfoState == none)
				{
					`log("Dark XCom: ERROR! Could not find DarkUnitComponent on a soldier at MOCX HQ!", ,'DarkXCom');
					continue;
				}

				if(InfoState != none) //check if it's this unit we're checking
				{
					EnemyUnit = XComGameState_Unit(History.GetGameStateForObjectID(InfoState.AssignedUnit.ObjectID));

					if(EnemyUnit == none)
					{
						`log("Dark XCom: Could not find tactical unit for capture check", ,'DarkXCom');
						continue;
					}

					if(EnemyUnit.GetReference().ObjectID != KilledUnit.GetReference().ObjectID)
						continue; //if we get no logs here, we know it's because we didn't find a match

				}
				//if we're here, we found a match and need to roll
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Owner Unit Died");
				LostHP = EnemyUnit.HighestHP - EnemyUnit.LowestHP;
				NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.ModifyStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));

				if(class'UnitDarkXComUtils'.static.WasCaptureSuccessful(NewInfoState, LostHP))
				{
					`log("Dark XCom: unit successfully captured", , 'DarkXCom');
					class'UnitDarkXComUtils'.static.GiveSoldierToXCOM(EnemyUnit, NewInfoState, NewGameState);
					GiveLootToXCOM(NewGameState, EnemyUnit, true);
					`GAMERULES.SubmitGameState(NewGameState);
				}

				else
				{
					`log("Dark XCom: unit died on capture attempt", , 'DarkXCom');
					GiveLootToXCOM(NewGameState, EnemyUnit);
					`GAMERULES.SubmitGameState(NewGameState);
				}

				break; //we can break since we found a match and either captured, or killed this unit
			}
	}
	if(NewInfoState != none) //this let us know we should play a message here, since this wouldn't exist without the unit being rolled for capture
	{
		kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		kTag.StrValue0 = class'UnitDarkXComUtils'.static.GetFullName(EnemyUnit);

		Presentation = `PRES;
		if(NewInfoState.bRecruited)
		{
		Presentation.NotifyBanner(default.UnitCapturedTitle, "img:///UILibrary_XPACK_Common.WorldMessage", class'UnitDarkXComUtils'.static.GetFullName(EnemyUnit), `XEXPAND.ExpandString(default.UnitCaptured),  eUIState_Good);

		`SOUNDMGR.PlayPersistentSoundEvent("UI_Blade_Positive");
		
		}

		if(!NewInfoState.bRecruited)
		{
		Presentation.NotifyBanner(default.UnitDiedTitle, "img:///UILibrary_XPACK_Common.WorldMessage", class'UnitDarkXComUtils'.static.GetFullName(EnemyUnit), `XEXPAND.ExpandString(default.UnitDied),  eUIState_Bad);

		`SOUNDMGR.PlayPersistentSoundEvent("UI_Blade_Negative");
		
		}
	}
	return ELR_NoInterrupt;
}

static function X2EventListenerTemplate CreateGremlinDeathEvent()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'MOCXGremlinDeathEvent');

	Template.RegisterInTactical = true;
	Template.AddEvent('UnitDied', IsOwnerDead);

	return Template;
}


static function EventListenerReturn IsOwnerDead(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, OwnerState, CosmeticUnit;
	local XComGameState NewGameState;
	local XComGameState_Item ItemState;
	local XComGameStateContext_ChangeContainer ChangeContext;

	UnitState = XComGameState_Unit(EventSource);
	foreach GameState.IterateByClassType(class'XComGameState_Item', ItemState)
	{

		if(ItemState.OwnerStateObject.ObjectID > 0)
		{
			History = `XCOMHISTORY;
			OwnerState = XComGameState_Unit(History.GetGameStateForObjectID(ItemState.OwnerStateObject.ObjectID));

			if(UnitState.ObjectID == OwnerState.ObjectID) //owner dead, pls kill us
			{
				CosmeticUnit = XComGameState_Unit(History.GetGameStateForObjectID(ItemState.CosmeticUnitRef.ObjectID));

				if(!CosmeticUnit.IsAlive());
					return ELR_NoInterrupt; //no need to kill ourselves if we're already dead
					
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Owner Unit Died");
				ChangeContext = XComGameStateContext_ChangeContainer(NewGameState.GetContext());
				ChangeContext.BuildVisualizationFn = ItemState.ItemOwnerDeathVisualization;
				CosmeticUnit = XComGameState_Unit(NewGameState.ModifyStateObject(CosmeticUnit.Class, CosmeticUnit.ObjectID));
				CosmeticUnit.SetCurrentStat(eStat_HP, 0);
				`GAMERULES.SubmitGameState(NewGameState);
				break; //
			}
		}

			
	}

	return ELR_NoInterrupt;
}

static function X2AbilityPointTemplate CreateMOCXEvacEvent()
{
	local X2AbilityPointTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AbilityPointTemplate', Template, 'MOCXEvac');
	Template.AddEvent('UnitEvacuated', CheckForEvac);

	return Template;
}

static function X2AbilityPointTemplate CreateMOCXKillEvent()
{
	local X2AbilityPointTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AbilityPointTemplate', Template, 'MOCXKill');
	Template.AddEvent('UnitDied', CheckForMOCXKill);

	return Template;
}

static function X2AbilityPointTemplate CreateMOCXCaptureEvent()
{
	local X2AbilityPointTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AbilityPointTemplate', Template, 'MOCXCapture');
	Template.AddEvent('UnitEvacuated', CheckForCapture);

	return Template;
}

static protected function EventListenerReturn CheckForMOCXKill(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local X2AbilityPointTemplate APTemplate;
	local int Roll;
	local XComGameStateContext_AbilityPointEvent EventContext;

	KilledUnit = XComGameState_Unit(EventSource);
	BattleData = XComGameState_BattleData( `XCOMHISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	APTemplate = GetAbilityPointTemplate( 'MOCXKill' );

	// bad data somewhere
	if ((APTemplate == none) || (BattleData == none) || (KilledUnit == none))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier' || KilledUnit.GetMyTemplateName() == 'DarkRookie' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M2' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M3')
		return ELR_NoInterrupt;

	
	Roll = class'Engine'.static.GetEngine().SyncRand(100, "RollForAbilityPoint");
	if (Roll < APTemplate.Chance)
	{
		EventContext = XComGameStateContext_AbilityPointEvent( class'XComGameStateContext_AbilityPointEvent'.static.CreateXComGameStateContext() );
		EventContext.AbilityPointTemplateName = APTemplate.DataName;
		EventContext.AssociatedUnitRef = KilledUnit.GetReference( );
		EventContext.TriggerHistoryIndex = GameState.GetContext().GetFirstStateInEventChain().HistoryIndex;

		`TACTICALRULES.SubmitGameStateContext( EventContext );
	}
}


static protected function EventListenerReturn CheckForEvac(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local X2AbilityPointTemplate APTemplate;
	local int Roll;
	local XComGameStateContext_AbilityPointEvent EventContext;

	KilledUnit = XComGameState_Unit(EventSource);
	BattleData = XComGameState_BattleData( `XCOMHISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	APTemplate = GetAbilityPointTemplate( 'MOCXEvac' );

	// bad data somewhere
	if ((APTemplate == none) || (BattleData == none) || (KilledUnit == none))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier' || KilledUnit.GetMyTemplateName() == 'DarkRookie' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M2' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M3')
		return ELR_NoInterrupt;

	// if it's a capture, abort
	if(KilledUnit.bBodyRecovered || !KilledUnit.IsAlive())
		return ELR_NoInterrupt;


	Roll = class'Engine'.static.GetEngine().SyncRand(100, "RollForAbilityPoint");
	if (Roll < APTemplate.Chance)
	{
		EventContext = XComGameStateContext_AbilityPointEvent( class'XComGameStateContext_AbilityPointEvent'.static.CreateXComGameStateContext() );
		EventContext.AbilityPointTemplateName = APTemplate.DataName;
		EventContext.AssociatedUnitRef = KilledUnit.GetReference( );
		EventContext.TriggerHistoryIndex = GameState.GetContext().GetFirstStateInEventChain().HistoryIndex;

		`TACTICALRULES.SubmitGameStateContext( EventContext );
	}
}


static protected function EventListenerReturn CheckForCapture(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local X2AbilityPointTemplate APTemplate;
	local int Roll;
	local XComGameStateContext_AbilityPointEvent EventContext;

	KilledUnit = XComGameState_Unit(EventSource);
	BattleData = XComGameState_BattleData( `XCOMHISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	APTemplate = GetAbilityPointTemplate( 'MOCXCapture' );

	// bad data somewhere
	if ((APTemplate == none) || (BattleData == none) || (KilledUnit == none))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier' || KilledUnit.GetMyTemplateName() == 'DarkRookie' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M2' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M3')
		return ELR_NoInterrupt;

	// if it's NOT a capture, abort
	if(!KilledUnit.bBodyRecovered || !KilledUnit.IsAlive())
		return ELR_NoInterrupt;


	Roll = class'Engine'.static.GetEngine().SyncRand(100, "RollForAbilityPoint");
	if (Roll < APTemplate.Chance)
	{
		EventContext = XComGameStateContext_AbilityPointEvent( class'XComGameStateContext_AbilityPointEvent'.static.CreateXComGameStateContext() );
		EventContext.AbilityPointTemplateName = APTemplate.DataName;
		EventContext.AssociatedUnitRef = KilledUnit.GetReference( );
		EventContext.TriggerHistoryIndex = GameState.GetContext().GetFirstStateInEventChain().HistoryIndex;

		`TACTICALRULES.SubmitGameStateContext( EventContext );
	}
}

static function GiveLootToXCOM(XComGameState NewGameState, XComGameState_Unit KilledUnit, optional bool IsAlive)
{
	local XComGameStateHistory History; 
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_Item ItemState, LootItem;
	local name LootName;
	local XComPresentationLayer Presentation;
	local Name LootTemplateName;
	local LootResults PendingAutoLoot;
	local int LootIndex;
	local array<Name> RolledLoot;

	Presentation = `PRES;
	History = `XCOMHistory;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	if(!IsAlive)
	{
		class'X2LootTableManager'.static.GetLootTableManager().RollForLootCarrier(KilledUnit.GetMyTemplate().Loot, PendingAutoLoot);

		if( PendingAutoLoot.LootToBeCreated.Length > 0 )
		{
			foreach PendingAutoLoot.LootToBeCreated(LootTemplateName)
			{

				ItemTemplate = ItemTemplateManager.FindItemTemplate(LootTemplateName);

				RolledLoot.AddItem(ItemTemplate.DataName);
			}
		}

		PendingAutoLoot.LootToBeCreated.Remove(0, PendingAutoLoot.LootToBeCreated.Length);

		PendingAutoLoot.AvailableLoot.Remove(0, PendingAutoLoot.AvailableLoot.Length);

		for( LootIndex = 0; LootIndex < RolledLoot.Length; ++LootIndex )
		{

			`log(" - " @ String(RolledLoot[LootIndex]));

			// create the loot item

			ItemState = ItemTemplateManager.FindItemTemplate(RolledLoot[LootIndex]).CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(ItemState);

			// assign the XComHQ as the new owner of the item
			ItemState.OwnerStateObject = XComHQ.GetReference();

			// add the item to the HQ's inventory of loot items
			XComHQ.PutItemInInventory(NewGameState, ItemState, true);
		}
		ItemTemplate = none;
	}
	if(KilledUnit.HasLoot()) //we have normal loot. Since this isn't recovered by extract corpses, we do it ourselves.
	{
		foreach KilledUnit.PendingLoot.LootToBeCreated(LootName)
		{	
			ItemTemplate = ItemTemplateManager.FindItemTemplate(LootName);
			if (ItemTemplate != none)
			{
				if (KilledUnit.bKilledByExplosion && !ItemTemplate.LeavesExplosiveRemains) //this shouldn't even proc, but just in case....
					continue;                                                                               //  item leaves nothing behind due to explosive death
				if (KilledUnit.bKilledByExplosion && ItemTemplate.ExplosiveRemains != '')
					ItemTemplate = ItemTemplateManager.FindItemTemplate(ItemTemplate.ExplosiveRemains);     //  item leaves a different item behind due to explosive death
			
				if (ItemTemplate != none)
				{
				
					LootItem = ItemTemplate.CreateInstanceFromTemplate(NewGameState);

					LootItem.OwnerStateObject = XComHQ.GetReference();
					XComHQ.PutItemInInventory(NewGameState, LootItem, true);
	
				}
			}
			class'XComGameState_Unit_DumbExtension'.static.RemoveAllLoot(KilledUnit); // so this doesn't get duplicated
		}


			Presentation.NotifyBanner(default.LootTitle, "img:///UILibrary_XPACK_Common.WorldMessage", KilledUnit.GetName(eNameType_Full), default.Loot,  eUIState_Good);

			`SOUNDMGR.PlayPersistentSoundEvent("UI_Blade_Positive");
	}

}
