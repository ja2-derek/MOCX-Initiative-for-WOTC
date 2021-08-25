class X2EventListener_TacticalDrop extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(DropMOCXListener());

	return Templates;
}


static function CHEventListenerTemplate DropMOCXListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'MOCX_DropSquad');
	//explanation: vanilla X2EvenetLIstenerTemplates do not specify deferrals, instead always being on ELD_OnStateSubmitted.
	//we're also using it because well, we're dropping gamestates, we should fit ourselves into order

	Template.RegisterInTactical = true;
	Template.AddCHEvent('PlayerTurnBegun', DropMOCXSquad, ELD_OnStateSubmitted);

	return Template;
}

static function EventListenerReturn DropMOCXSquad(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local Object ThisObj;
	local X2EventManager EventManager;
	local name SpawnTag, EncounterID;
	local XComTacticalMissionManager MissionManager;
	local int Index;
	local X2TacticalGameRuleset TacticalRules;
	local XComGameState NewGameState;
	local XComGameState_Player PlayerState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local bool AlreadyDOne;
	PlayerState = class'XComGameState_Player'.static.GetPlayerState(eTeam_XCom);
	XComHQ = `XCOMHQ;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(`XCOMHistory.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	NewGameState = GameState;
	AlreadyDone = `XCOMHistory.GetSingleGameStateObjectForClass(class'XComGameState_MOCXReinforcementSpawner') != none;
	// call in for our MOCX squad IF the MOCX sitrep is active, it's the aliens turn, and XCOM has revealed themselves
	// check first if we've already spawned the squad, then check if we already called for reinforcements
	if (PlayerState.IsAnySquadMemberRevealed() && (!class'UnitDarkXComUtils'.static.AlreadySpawnedSquad(DarkXComHQ) && !AlreadyDone))
	{
		
		PlayerState = XComGameState_Player(EventData);
		if( PlayerState.TeamFlag == eTeam_Alien )
		{
			EventManager = `XEVENTMGR;

			if( (XComHQ.TacticalGameplayTags.Find('SITREP_MOCX') != INDEX_NONE) )
			{
				//MissionManager = `TACTICALMISSIONMGR;
				`log("Creating new MOCX reinforcement spawner.", , 'DarkXCom');

					//TacticalRules = `TACTICALRULES;
					//GameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Activated Chosen Spawn");

					//EncounterID = MissionManager.ChosenSpawnTagToEncounterID[Index].EncounterID;
					class'XComGameState_MOCXReinforcementSpawner'.static.InitiateReinforcements('Blank',
						1,
						,
						,
						40, // 40 seems like a solid middle number
						, //testing if we don't need to pass a gamestate here
						,
						'ATT',
						true,
						false,
						true,
						true,
						false,
						true);

					//TacticalRules.SubmitGameState(NewGameState);
				
			}
		}
	}

	return ELR_NoInterrupt;
}
