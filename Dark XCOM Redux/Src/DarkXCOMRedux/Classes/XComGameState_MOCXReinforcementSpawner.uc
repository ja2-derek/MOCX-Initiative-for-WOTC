class XComGameState_MOCXReinforcementSpawner extends XComGAmeState_AIReinforcementSpawner;


function SpawnReinforcements()
{
	local XComGameState NewGameState;
	local XComGameState_AIReinforcementSpawner NewSpawnerState;
	local X2EventManager EventManager;
	local Object ThisObj;
	local XComAISpawnManager SpawnManager;
	local XGAIGroup SpawnedGroup;
	local X2GameRuleset Ruleset;
	local XComGameState_Item ItemState;

	EventManager = `XEVENTMGR;
	SpawnManager = `SPAWNMGR;
	Ruleset = `XCOMGAME.GameRuleset;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(default.SpawnReinforcementsChangeDesc);
	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = BuildVisualizationForUnitSpawning;

	NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGameState.ModifyStateObject(class'XComGameState_AIReinforcementSpawner', ObjectID));

	// spawn the units
	SpawnedGroup = SpawnManager.SpawnPodAtLocation(
		NewGameState,
		SpawnInfo,
		bMustSpawnInLOSOfXCOM,
		bDontSpawnInLOSOfXCOM,
		bDontSpawnInHazards);

	// clear the ref to this actor to prevent unnecessarily rooting the level
	SpawnInfo.SpawnedPod = None;

	// cache off the spawned unit IDs
	NewSpawnerState.SpawnedUnitIDs = SpawnedGroup.m_arrUnitIDs;

	foreach NewGameState.IterateByClassType(class'XComGameState_Item', ItemState)
	{
		ItemState.CreateCosmeticItemUnit(NewGameState);
	}
	ThisObj = self;
	EventManager.RegisterForEvent(ThisObj, 'SpawnReinforcementsComplete', OnSpawnReinforcementsComplete, ELD_OnStateSubmitted,, ThisObj);
	EventManager.TriggerEvent('SpawnReinforcementsComplete', ThisObj, ThisObj, NewGameState);

	NewGameState.GetContext().SetAssociatedPlayTiming(SPT_AfterSequential);

	Ruleset.SubmitGameState(NewGameState);
}

// TODO: update this function to better consider the space that an ATT requires
private function bool DoesLocationReallySupportATT(Vector TargetLocation)
{
	local TTile TargetLocationTile;
	local TTile AirCheckTile;
	local VoxelRaytraceCheckResult CheckResult;
	local XComWorldData WorldData;

	WorldData = `XWORLD;

		TargetLocationTile = WorldData.GetTileCoordinatesFromPosition(TargetLocation);
	AirCheckTile = TargetLocationTile;
	AirCheckTile.Z = WorldData.NumZ - 1;

	// the space is free if the raytrace hits nothing
	return (WorldData.VoxelRaytrace_Tiles(TargetLocationTile, AirCheckTile, CheckResult) == false);
}

// This is called after this reinforcement spawner has finished construction
function EventListenerReturn OnReinforcementSpawnerCreated(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_MOCXReinforcementSpawner NewSpawnerState;
	local X2EventManager EventManager;
	local Object ThisObj;
	local X2CharacterTemplate SelectedTemplate;
	local XComGameState_Player PlayerState;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSiteState;
	local XComAISpawnManager SpawnManager;
	local int AlertLevel, ForceLevel;
	local XComGameStateHistory History;
	local Name CharTemplateName;
	local X2CharacterTemplateManager CharTemplateManager;
	// Variables for Issue #278
	local array<X2DownloadableContentInfo> DLCInfos; 
	local int i; 
	// Variables for Issue #278

	CharTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	SpawnManager = `SPAWNMGR;
	History = `XCOMHISTORY;

	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	ForceLevel = BattleData.GetForceLevel();
	AlertLevel = BattleData.GetAlertLevel();

	if( BattleData.m_iMissionID > 0 )
	{
		MissionSiteState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

		if( MissionSiteState != None && MissionSiteState.SelectedMissionData.SelectedMissionScheduleName != '' )
		{
			AlertLevel = MissionSiteState.SelectedMissionData.AlertLevel;
			ForceLevel = MissionSiteState.SelectedMissionData.ForceLevel;
		}
	}

	// Select the spawning visualization mechanism and build the persistent in-world visualization for this spawner
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));

	NewSpawnerState = XComGameState_MOCXReinforcementSpawner(NewGameState.ModifyStateObject(class'XComGameState_MOCXReinforcementSpawner', ObjectID));

	// choose reinforcement spawn location

	// build a character selection that will work at this location
	SpawnManager.SelectPodAtLocation(NewSpawnerState.SpawnInfo, ForceLevel, AlertLevel, BattleData.ActiveSitReps);

	// Start Issue #278
	//LWS: Added hook to allow post-creation adjustment of instantiated encounter info
	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	for(i = 0; i < DLCInfos.Length; ++i)
	{
		DLCInfos[i].PostReinforcementCreation(NewSpawnerState.SpawnInfo.EncounterID, NewSpawnerState.SpawnInfo, ForceLevel, AlertLevel, BattleData, self);
	}
	// End Issue #278

	if( NewSpawnerState.SpawnVisualizationType == 'ChosenSpecialNoReveal' ||
	   NewSpawnerState.SpawnVisualizationType == 'ChosenSpecialTopDownReveal' )
	{
		NewSpawnerState.SpawnInfo.bDisableScamper = true;
	}

	// explicitly disabled all timed loot from reinforcement groups
	NewSpawnerState.SpawnInfo.bGroupDoesNotAwardLoot = true;

	// fallback to 'PsiGate' visualization if the requested visualization is using 'ATT' but that cannot be supported
	if( NewSpawnerState.SpawnVisualizationType == 'ATT' )
	{
		// determine if the spawning mechanism will be via ATT or PsiGate
		//  A) ATT requires open sky above the reinforcement location
		//  B) ATT requires that none of the selected units are oversized (and thus don't make sense to be spawning from ATT)
		if( DoesLocationReallySupportATT(NewSpawnerState.SpawnInfo.SpawnLocation) )
		{
			// determine if we are going to be using psi gates or the ATT based on if the selected templates support it
			foreach NewSpawnerState.SpawnInfo.SelectedCharacterTemplateNames(CharTemplateName)
			{
				SelectedTemplate = CharTemplateManager.FindCharacterTemplate(CharTemplateName);

				if( !SelectedTemplate.bAllowSpawnFromATT )
				{
					NewSpawnerState.SpawnVisualizationType = 'PsiGate';
					break;
				}
			}
		}
		else
		{
			NewSpawnerState.SpawnVisualizationType = 'PsiGate';
		}
	}

	if( NewSpawnerState.SpawnVisualizationType != '' && 
	   NewSpawnerState.SpawnVisualizationType != 'TheLostSwarm' && 
	   NewSpawnerState.SpawnVisualizationType != 'ChosenSpecialNoReveal' &&
	   NewSpawnerState.SpawnVisualizationType != 'ChosenSpecialTopDownReveal' )
	{
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = NewSpawnerState.BuildVisualizationForSpawnerCreation;
		NewGameState.GetContext().SetAssociatedPlayTiming(SPT_AfterSequential);
	}

	`TACTICALRULES.SubmitGameState(NewGameState);

	// no countdown specified, spawn reinforcements immediately
	if( Countdown <= 0 )
	{
		NewSpawnerState.SpawnReinforcements();
	}
	// countdown is active, need to listen for AI Turn Begun in order to tick down the countdown
	else
	{
		EventManager = `XEVENTMGR;
		ThisObj = self;

		PlayerState = class'XComGameState_Player'.static.GetPlayerState(NewSpawnerState.SpawnInfo.Team);
		EventManager.RegisterForEvent(ThisObj, 'PlayerTurnBegun', OnTurnBegun, ELD_OnStateSubmitted, , PlayerState);
	}

	return ELR_NoInterrupt;
}

static function bool InitiateReinforcements(
	Name EncounterID, 
	optional int OverrideCountdown = -1, 
	optional bool OverrideTargetLocation,
	optional const out Vector TargetLocationOverride,
	optional int IdealSpawnTilesOffset,
	optional XComGameState IncomingGameState,
	optional bool InKismetInitiatedReinforcements,
	optional Name InSpawnVisualizationType = 'ATT',
	optional bool InDontSpawnInLOSOfXCOM,
	optional bool InMustSpawnInLOSOfXCOM,
	optional bool InDontSpawnInHazards,
	optional bool InForceScamper,
	optional bool bAlwaysOrientAlongLOP, 
	optional bool bIgnoreUnitCap)
{
	local XComGameState_MOCXReinforcementSpawner NewAIReinforcementSpawnerState;
	local XComGameState NewGameState;
	local XComTacticalMissionManager MissionManager;
	local ConfigurableEncounter Encounter;
	local XComAISpawnManager SpawnManager;
	local Vector DesiredSpawnLocation;

	if( !bIgnoreUnitCap && LivingUnitCapReached(InSpawnVisualizationType == 'TheLostSwarm') )
	{
		return false;
	}
	`log("Creating MOCX squad reinforcements", ,'DarkXCom');
	SpawnManager = `SPAWNMGR;

	//MissionManager = `TACTICALMISSIONMGR;
	//MissionManager.GetConfigurableEncounter(EncounterID, Encounter);

	if (IncomingGameState == none)
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating Reinforcement Spawner");
	else
		NewGameState = IncomingGameState;

	// Update AIPlayerData with CallReinforcements data.
	NewAIReinforcementSpawnerState = XComGameState_MOCXReinforcementSpawner(NewGameState.CreateNewStateObject(class'XComGameState_MOCXReinforcementSpawner'));
	NewAIReinforcementSpawnerState.SpawnInfo.EncounterID = 'MOCXDummiesX4'; // go with a known safe pod name so the reinforcement bits work properly

	NewAIReinforcementSpawnerState.SpawnVisualizationType = InSpawnVisualizationType;
	NewAIReinforcementSpawnerState.bDontSpawnInLOSOfXCOM = InDontSpawnInLOSOfXCOM;
	NewAIReinforcementSpawnerState.bMustSpawnInLOSOfXCOM = InMustSpawnInLOSOfXCOM;
	NewAIReinforcementSpawnerState.bDontSpawnInHazards = InDontSpawnInHazards;
	NewAIReinforcementSpawnerState.bForceScamper = InForceScamper;

	if( OverrideCountdown >= 0 )
	{
		NewAIReinforcementSpawnerState.Countdown = OverrideCountdown;
	}
	else
	{
		NewAIReinforcementSpawnerState.Countdown = 1;
	}

	if( OverrideTargetLocation )
	{
		DesiredSpawnLocation = TargetLocationOverride;
	}
	else
	{
		DesiredSpawnLocation = SpawnManager.GetCurrentXComLocation();
	}

	NewAIReinforcementSpawnerState.SpawnInfo.SpawnLocation = SpawnManager.SelectReinforcementsLocation(
		NewAIReinforcementSpawnerState, 
		DesiredSpawnLocation, 
		IdealSpawnTilesOffset, 
		InMustSpawnInLOSOfXCOM,
		InDontSpawnInLOSOfXCOM,
		InSpawnVisualizationType == 'ATT',
		bAlwaysOrientAlongLOP); // ATT vis type requires vertical clearance at the spawn location

	NewAIReinforcementSpawnerState.bKismetInitiatedReinforcements = InKismetInitiatedReinforcements;

	if (IncomingGameState == none)
		`TACTICALRULES.SubmitGameState(NewGameState);

	return true;
}