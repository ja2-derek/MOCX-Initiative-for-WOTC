//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_XpackMissionSources.uc
//  AUTHOR:  Mark Nauta  --  06/23/2016
//  PURPOSE: Define new XPACK mission source templates
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2StrategyElement_MOCXMissionSources extends X2StrategyElement_XPACKMissionSources;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;


	MissionSources.AddItem(CreateMOCXTemplate('MissionSource_MOCXOffsite'));
	MissionSources.AddItem(CreateMOCXTemplate('MissionSource_MOCXAssault'));
	MissionSources.AddItem(CreateMOCXTemplate('MissionSource_MOCXTraining'));
		`log("Dark XCOM: bulding mission sources", ,'DarkXCom');
	return MissionSources;
}



// ALIEN NETWORK
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateMOCXTemplate(name TemplateName)
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, TemplateName);
	Template.bIncreasesForceLevel = false;
	Template.bDisconnectRegionOnFail = false;
	Template.DifficultyValue = 2;

	Template.MissionImage = "img://UILibrary_Common.Councilman_small";

	if(TemplateName == 'MissionSource_MOCXOffsite')
	{
		Template.OnSuccessFn = OffsiteOnSuccess;
		Template.DifficultyValue = 3;
		Template.OverworldMeshPath = "UI_3D.Overwold_Final.AlienFacility";
		Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonthAndStart;
	}

	if(TemplateName == 'MissionSource_MOCXTraining')
	{
		Template.OverworldMeshPath = "UI_3D.Overwold_Final.ResOps";
		Template.OnSuccessFn = TrainingOnSuccess;
		Template.DifficultyValue = 9; //this gets us around the difficulty cap
		Template.CustomMusicSet = 'LostAndAbandoned';
		Template.GetMissionDifficultyFn = GetMissionDifficultyFromTemplate;
	}

	if(TemplateName == 'MissionSource_MOCXAssault')
	{
		Template.OnSuccessFn = AssaultOnSuccess;
		Template.DifficultyValue = 7;
		Template.CustomMusicSet = 'Tutorial'; //avenger def music
		Template.OverworldMeshPath = "UI_3D.Overwold_Final.GP_BroadcastOfTruth";
		Template.GetMissionDifficultyFn = GetMissionDifficultyFromTemplate;
	}

	Template.OnFailureFn = MOCXOnFailure;
	Template.OnExpireFn = MOCXOnExpire;

	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	Template.bIgnoreDifficultyCap = true;
	//Template.MissionPopupFn = OpenMOCXMissionBlades;

	return Template;
}


static function int GetMissionDifficultyFromMonthAndStart(XComGameState_MissionSite MissionState)
{
	local TDateTime StartDate;
	local array<int> MonthlyDifficultyAdd;
	local int Difficulty, MonthDiff;

	class'X2StrategyGameRulesetDataStructures'.static.SetTime(StartDate, 0, 0, 0, class'X2StrategyGameRulesetDataStructures'.default.START_MONTH,
		class'X2StrategyGameRulesetDataStructures'.default.START_DAY, class'X2StrategyGameRulesetDataStructures'.default.START_YEAR);

	Difficulty = 1;
	MonthDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMonths(class'XComGameState_GeoscapeEntity'.static.GetCurrentTime(), StartDate);
	MonthlyDifficultyAdd = GetMonthlyDifficultyAdd();

	if(MonthDiff >= MonthlyDifficultyAdd.Length)
	{
		MonthDiff = MonthlyDifficultyAdd.Length - 1;
	}

	Difficulty += MonthlyDifficultyAdd[MonthDiff];
	Difficulty += MissionState.GetMissionSource().DifficultyValue;

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty,
						class'X2StrategyGameRulesetDataStructures'.default.MaxMissionDifficulty);

	return Difficulty;
}

static function OffsiteOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ.ObjectID));
	}


	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionCompleted');
	
	DarkXComHQ.bOffSiteDone = true;


	if(DarkXComHQ.bSquadSizeI) 
		ActivateDarkEvent(NewGameState, 'DarkEvent_HealthBoosters', true); //this will do nothing if it's already active

	if(!DarkXComHQ.bSquadSizeI)
		ActivateDarkEvent(NewGameState, 'DarkEvent_SquadSizeI');



	`XEVENTMGR.TriggerEvent('MOCXOffsite_Victory', , , NewGameState);
}


static function TrainingOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ.ObjectID));
	}


	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionCompleted');
	
	DarkXComHQ.bTrainingDone = true;


	if(DarkXComHQ.bHasCoil && !DarkXComHQ.bHasPlasma)
		ActivateDarkEvent(NewGameState, 'DarkEvent_PlasmaTier');

	if(!DarkXComHQ.bHasCoil)
		ActivateDarkEvent(NewGameState, 'DarkEvent_CoilTier');

	`XEVENTMGR.TriggerEvent('MOCXTraining_Victory', , , NewGameState);
}


static function AssaultOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ.ObjectID));
	}


	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionCompleted');

	DarkXComHQ.bIsActive = false;
	DarkXComHQ.bIsDestroyed = true;

	`XEVENTMGR.TriggerEvent('MOCXHQ_Destroyed', , , NewGameState);

}

static function MOCXOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	//MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionFailed');

	//`XEVENTMGR.TriggerEvent('RescueSoldierComplete', , , NewGameState);
}

static function MOCXOnExpire(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionFailed');
}


static function ActivateDarkEvent(XComGameState NewGameState, name DarkEventName, optional bool ExitIfActive)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_DarkEvent DarkEventState;
	local StateObjectReference ActivatedEventRef;
	local bool bExistingDarkEvent;
	local X2StrategyElementTemplate DETemplate;
	local DynamicPropertySet PropertySet; //this is so we make sure the alert doesn't appear until we're on the Geoscape
	History = `XCOMHISTORY;
		bExistingDarkEvent = false;

	foreach History.IterateByClassType(class'XComGameState_DarkEvent', DarkEventState)
	{
		if(DarkEventState.GetMyTemplateName() == DarkEventName)
		{
			bExistingDarkEvent = true;
			break;
		}
	}

	if( !bExistingDarkEvent )
	{
		DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(DarkEventName);
		if( DETemplate == None )
		{
			return;
		}
	}

	if(ExitIfActive && DarkEventState != none && DarkEventState.TimesSucceeded > 0){
		return; //don't do anything if the event is already active and we shouldn't do anything
	}

	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
	if( bExistingDarkEvent )
	{
		DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
	}
	else
	{
		DarkEventState = XComGameState_DarkEvent(NewGameState.CreateNewStateObject(class'XComGameState_DarkEvent', DETemplate));
	}
	ActivatedEventRef = DarkEventState.GetReference();
	DarkEventState.TimesSucceeded++;
	DarkEventState.Weight += DarkEventState.GetMyTemplate().WeightDeltaPerActivate;
	DarkEventState.Weight = Clamp(DarkEventState.Weight, DarkEventState.GetMyTemplate().MinWeight, DarkEventState.GetMyTemplate().MaxWeight);
	DarkEventState.OnActivated(NewGameState);

	if( DarkEventState.GetMyTemplate().MaxDurationDays > 0 || DarkEventState.GetMyTemplate().bLastsUntilNextSupplyDrop )
	{
		AlienHQ.ActiveDarkEvents.AddItem(DarkEventState.GetReference());
		DarkEventState.StartDurationTimer();
	}


	if(ActivatedEventRef.ObjectID != 0)
	{
		//`GAME.GetGeoscape().Pause();
		//`HQPRES.UIDarkEventActivated(ActivatedEventRef);
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_MOCXDarkEvent', 'UIAlert_DarkEvent', none, false, false, true, false);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'DarkEventRef', ActivatedEventRef.ObjectID);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet);
	}

}