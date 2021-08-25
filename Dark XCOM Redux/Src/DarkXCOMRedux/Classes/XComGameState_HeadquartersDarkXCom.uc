class XComGameState_HeadquartersDarkXCOM extends XComGameState_BaseObject config (DarkXCOM);

var array<StateObjectReference> Crew;	//All MOCX crew members
var array<StateObjectReference> DeadCrew; //the fallen 

var array<StateObjectReference>  Squad; // Which soldiers are selected to go an a mission

// Modifiers
var bool							bSquadSizeI; // Squad Size bonuses
var bool							bSquadSizeII; 
var bool							bGeneticPCS; // gene mod equivalents
var bool							bAdvancedMECs; // SPARK equivalents
var bool							bHasCoil; //is at coil + power armor tech level
var bool							bHasPlasma; //is at plasma tech level
var bool							bAdvancedICUs; //50% faster healing

//HQ status
var bool							bIsDestroyed; //did XCOM set us up the bomb
var bool							bIsActive; //is it May yet

var bool							bChainStarted; //have we started the mission chain?
var bool							bOffSiteDone; //completed offsite storage mission
var bool							bTrainingFound; //did we spawn the training raid?
var bool							bTrainingDone; //completed training raid mission
var bool							bHQUnlocked; //did we spawn the HQ mission?

//sitrep status
var bool							bSITREPActive; //we got a SITREP active, don't roll again. Set this to false every time we do a mission: forced SITREPs on missions should be unaffected.
var int								NumOfMissionsSITREPActive; //this is a failsafe measure: if we pass X amount of missions then we should assume we should stop assuming the SITREP is active.

// last mission info, set from OnPostMission. Needed for PhotoboothInfo
// This is XCOM-centric. It records whether MOCX was active in the last mission XCOM did, and if so, with what squad
var bool							LastMission_bWasActive;
var array<StateObjectReference>		LastMission_Squad;

var int								ChanceToRoll; //current chance for MOCX to appear on a mission
var int								NumSinceAppearance; //how many missions have passed since last appearance?
var int								HighestSoldierRank;
//class stuff
var() array<name>                   SoldierClassDeck;   //classes we can use: be sure to update this when available
var() array<SoldierClassCount>		SoldierClassDistribution;


//project variables
var bool							bRunningProject; //used to determine if MOCX HQ is running a covert action related project today
var TDateTime						StartDateTime;
var TDateTime						EndDateTime; //when the project's planned to end
var name							ProjectName; //the project we're working on. (EXPECTS DARK EVENTS FOR NOW)
var bool							bProjectCompleted; //did we finish?
var bool							bProjectCancelled; //did we lose out on a project?
var bool							bWaitingForAction; //are we waiting on a covert action result?
//config variables

var config int StartingSoldiers; //starting MOCX soldiers
var config int MonthlyReinforcements; //replacements it can get due to losses

var config int MaxSoldiers; //how many soldiers MOCX can have in total
var config int StartingSquadSize; //the initial size of MOCX squads

var config int BaseChance; //what's the minimum that MOCX can roll to appear on a mission?
var config int MissingChance; //how much does the chance increase by per mission MOCX hasn't appeared in?

var config int BaseMonthsForRanks; //how many months does it take for replacement soldiers to start off with better ranks?

var config int AdvancedMECChance; //what's the chance of an advanced MEC deploying on a mission?


//eteam_one shenanigans

var config int RebelChance; //if above 0, roll this against 100. If result is less than that, we spawn into eTeam_One.


// pod configuration
var config bool ManualEncounterZone; // use this to have the .ini control the sizes
var config int	configAlongLOP;
var config int	configFromLOP;
var config int configEncounterZoneWidth;
var config int configEncounterZoneDepthOverride;
function bool ShouldDoFailsafe()
{
	if(bSITREPActive && NumOfMissionsSITREPActive > 3) //after 3 missions, we assume the player has either done the SITREP or skipped it
		return true;

	return false;
}


//--------------------------------------------------------------------------------------
// START AND MONTHLY TRANSITIONS
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
function SetUpHeadquarters(XComGameState StartState)
{
	//local XComGameState_HeadquartersDarkXCom DarkXComHQ;
//
	//DarkXComHQ = XComGameState_HeadquartersDarkXCom(StartState.CreateStateObject(class'XComGameState_HeadquartersDarkXCom'));
	//StartState.AddStateObject(DarkXComHQ);
//
	CreateStartingOrEmergencySoldiers(StartState);
}

function EndOfMonth(XComGameState NewGameState, optional XComGameState_HeadquartersResistance ResHQ)
{

	if(bIsActive && !bIsDestroyed)
	{
		CheckForPromotions(NewGameState);
		ConsiderProject(NewGameState, self);
	}
	if(Crew.Length < (StartingSoldiers / 2))
		CreateStartingOrEmergencySoldiers(NewGameState, ResHQ, self);

	if(Crew.Length >= (StartingSoldiers / 2) && bIsActive)
		AddReinforcementSoldiers(NewGameState, ResHQ, self);


}

function bool Update(XComGameState NewGameState)
{
	local UIStrategyMap StrategyMap;
	local bool bUpdated;

	StrategyMap = `HQPRES.StrategyMap2D;
	bUpdated = false;
	
	if(bIsDestroyed) //don't update destroyed HQs
		return bUpdated;

	// Don't trigger end of month while the Avenger or Skyranger are flying, or if another popup is already being presented
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight && !`HQPRES.ScreenStack.IsCurrentClass(class'UIAlert'))
	{
		if(ReassessRecoveryTime(self, NewGameState));
			bUpdated = true;

		if(AssessProjectTime(self, NewGameState));
			bUpdated = true;
	}

	return bUpdated;

}

function bool AssessProjectTime(XComGameState_HeadquartersDarkXCom DarkXComHQ, XComGameState NewGameState)
{
	local XComGameState_CovertAction ActionState;
	local XComGameStateHistory		History;

	if(!DarkXComHQ.bRunningProject)
		return false; //we don't have a project, abort

	History = `XCOMHISTORY;
	//if the player is doing a covert action to stop us, delay the time to complete the project by a month. It'll either be removed before then or the player will have failed (not possible in vanilla), in which case we will have added mod support to instant complete the project in exchange.
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if(ActionState.GetMyTemplateName() == 'CovertAction_MOCXCancelProject' && (ActionState.bStarted && !ActionState.bCompleted && (ActionState.HoursToComplete > 0)) && !DarkXComHQ.bWaitingForAction) //this is dumb but we have to account for this
		{
			class'X2StrategyGameRulesetDataStructures'.static.AddHours(DarkXComHQ.EndDateTime, (ActionState.HoursToComplete + 168)); //add a week juuuust to be safe
			DarkXComHQ.bWaitingForAction = true;
			return true;
		}
	}
	//if they're NOT, then we can just assess the time and see if the project should be completed

	if(class'X2StrategyGameRulesetDataStructures'.static.LessThan(DarkXComHQ.EndDateTime, `STRATEGYRULES.GameTime) && !DarkXComHQ.bProjectCancelled && !DarkXComHQ.bWaitingForAction)
	{
		DarkXComHQ.bProjectCompleted = true;
		return true;
	}

	return false;
}

function bool ReassessRecoveryTime(XComGameState_HeadquartersDarkXCom DarkXComHQ, XComGameState NewGameState)
{
	local XComGameStateHistory					History;
	local XComGameState_Unit					UnitState;
	local XComGameState_Unit_DarkXComInfo		InfoState, NewInfoState;
	local int									i;
	local bool bUpdated;
	History = `XCOMHISTORY;
	bUpdated = false;
	for(i = 0; i < DarkXComHQ.Crew.Length; i++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Crew[i].ObjectID));
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(UnitState);

		if(UnitState != none && InfoState != none && InfoState.bIsAlive)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.ModifyStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));

			if(NewInfoState.GetRecoveryPoints() > 0)
			{
				NewInfoState.AssessRecovery(); 
				bUpdated = true;
			}
		}
	}

	return bUpdated;
}

function ConsiderProject(XComGameState NewGameState, optional XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local array<X2DarkEventTemplate> ProjectTemplates, UsableTemplates;
	local X2DarkEventTemplate TemplateToConsider, ProjectInUse;
	local XComGameState_DarkEvent DummyState;
	local int HoursToAdd, MinDays, MaxDays;

	if(DarkXComHQ == none)
	{
		foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
		{
			break;
		}

	}
	
	if(DarkXComHQ.bRunningProject)
		return; //we already have a project running

	GetProjectEvents(ProjectTemplates);
	DummyState = new class'XComGameState_DarkEvent';
	foreach ProjectTemplates(TemplateToConsider)
	{
		if(TemplateToConsider.CanActivateFn(DummyState) && IsNotInProgress(TemplateToConsider)) //check if we can activate the template, AND if this isn't already a dark event
			UsableTemplates.AddItem(TemplateToConsider);
	}


	if(UsableTemplates.Length > 0) //if we have at least one template available...
	{
		ProjectInUse = UsableTemplates[`SYNC_RAND(UsableTemplates.Length)];
		ProjectName = ProjectInUse.DataName;
		DarkXComHQ.StartDateTime = `STRATEGYRULES.GameTime;

		DarkXComHQ.EndDateTime = DarkXComHQ.StartDateTime;

		if(ProjectInUse.MaxActivationDays > 0 || ProjectInUse.MinActivationDays > 0)
		{
			MinDays = ProjectInUse.MinActivationDays;
			MaxDays = ProjectInUse.MaxActivationDays;
		}
		else
		{
			MinDays = ProjectInUse.MinActivationDays;
			MaxDays = ProjectInUse.MaxActivationDays;
		}

		HoursToAdd = (MinDays * 24) + `SYNC_RAND_STATIC((MaxDays * 24) - (MinDays * 24) + 1);
		HoursToAdd += (MinDays * 24) + `SYNC_RAND_STATIC((MaxDays * 24) - (MinDays * 24) + 1); //we double it so the player gets a chance to counter it
		class'X2StrategyGameRulesetDataStructures'.static.AddHours(DarkXComHQ.EndDateTime, HoursToAdd);
		DarkXComHQ.bRunningProject = true;
		DarkXComHQ.bProjectCancelled = false;
	}

	return;
}
static function bool IsNotInProgress(X2DarkEventTemplate Template)
{
	local XComGameStateHistory History;
	local XComGameState_DarkEvent DarkEventState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_DarkEvent', DarkEventState)
	{
		if(DarkEventState.GetMyTemplateName() == Template.DataName && (!DarkEventState.CanActivate() || DarkEventState.TimeRemaining > 0))
			return false; //dark event was either already played, or is in-progress
	}

	return true; //did not find dark event at all, presume true
}
function GetProjectEvents(out array<X2DarkEventTemplate> ProjectTemplates)
{
	local X2StrategyElementTemplate DETemplate;

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_CoilTier');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_PlasmaTier');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_SquadSizeI');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_SquadSizeII');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_ICU');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_AdvancedMECs');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	DETemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('DarkEvent_GeneticPCS');

	if( DETemplate == None )
	{
		return;
	}
	else
	{
		ProjectTemplates.AddItem(X2DarkEventTemplate(DETemplate));
	}

	return;
}

function CheckForPromotions(XComGameState NewGameState)
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	
	for(i = 0; i < Crew.Length; i++)
	{

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState != none)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			NewInfoState.MonthsInService += 1;
			if(NewInfoState.MonthsSinceLastPromotion >= NewInfoState.PromotionThreshold)
			{
				class'UnitDarkXComUtils'.static.GivePromotion(NewInfoState);
				NewInfoState.MonthsSinceLastPromotion = 0;
			}

			else
			{
				NewInfoState.MonthsSinceLastPromotion += 1;
			}

		}

	}

}
//--------------------------------------------------------------------------------------
// SOLDIER HANDLING
//---------------------------------------------------------------------------------------
function CreateStartingOrEmergencySoldiers(XComGameState StartState, optional XComGameState_HeadquartersResistance ResHQ, optional XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local XComGameState_Unit NewSoldierState;	
	//local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	//local XGCharacterGenerator CharacterGenerator;
	local int Index, AdditionalRanks;
	//local XComGameState_GameTime GameTime;
	local XComOnlineProfileSettings ProfileSettings;
	local XComGameState_Unit_DarkXComInfo InfoState;

	//assert(StartState != none);

	if(DarkXComHQ == none)
	{
		foreach StartState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
		{
			break;
		}

	}


	//foreach StartState.IterateByClassType(class'XComGameState_GameTime', GameTime)
	//{
		//break;
	//}
	//`assert( GameTime != none );


	ProfileSettings = `XPROFILESETTINGS;

	// Starting soldiers
	for( Index = 0; Index < StartingSoldiers; ++Index )
	{
		NewSoldierState = `CHARACTERPOOLMGR.CreateCharacter(StartState, ProfileSettings.Data.m_eCharPoolUsage, 'DarkSoldier');
		//CharacterGenerator = `XCOMGRI.Spawn(NewSoldierState.GetMyTemplate().CharacterGeneratorClass);
		//`assert(CharacterGenerator != none);

		NewSoldierState.RandomizeStats();
		NewSoldierState.ApplyInventoryLoadout(StartState);

		InfoState = XComGameState_Unit_DarkXComInfo(StartState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo'));
		InfoState.InitComponent(SelectNextSoldierClass(), NewSoldierState.GetReference().ObjectID);
		//NewSoldierState.AddComponentObject(InfoState);
		StartState.AddStateObject(InfoState);

		if(InfoState.GetClassName() == 'DarkReclaimed') //handling for Reclaimed: they should look like Skirmishers
			class'UnitDarkXComUtils'.static.DoReclaimedAppearance(StartState, NewSoldierState);

		if(ResHQ != none && ((ResHQ.NumMonths / BaseMonthsForRanks) > 1))
		{
		AdditionalRanks = (ResHQ.NumMonths / BaseMonthsForRanks);
		AdditionalRanks = Clamp(AdditionalRanks, 1, 3); //clamping because shit gets stupid past a certain rank
		InfoState.RankUp(AdditionalRanks);

		}

		DarkXComHQ.AddToCrew(StartState, NewSoldierState);
		//NewSoldierState.m_RecruitDate = GameTime.CurrentTime; // AddToCrew does this, but during start state creation the StrategyRuleset hasn't been created yet

		StartState.AddStateObject( NewSoldierState );
	}

}


function AddReinforcementSoldiers(XComGameState StartState, optional XComGameState_HeadquartersResistance ResHQ, optional XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local XComGameState_Unit NewSoldierState;	
	//local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	//local XGCharacterGenerator CharacterGenerator;
	local int Index, AdditionalRanks;
//	local XComGameState_GameTime GameTime;
	local XComOnlineProfileSettings ProfileSettings;
	local XComGameState_Unit_DarkXComInfo InfoState;

	//assert(StartState != none);

	if(DarkXComHQ == none)
	{
		foreach StartState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
		{
			break;
		}

	}

	//foreach StartState.IterateByClassType(class'XComGameState_GameTime', GameTime)
	//{
		//break;
	//}
	//`assert( GameTime != none );


	ProfileSettings = `XPROFILESETTINGS;

	// Starting soldiers
	for( Index = 0; Index < MonthlyReinforcements; ++Index )
	{
		if(Crew.Length >= MaxSoldiers)
		{
		`log("Dark XCOM: Already at max capacity.", ,'DarkXCom');
			break;
		}
		NewSoldierState = `CHARACTERPOOLMGR.CreateCharacter(StartState, ProfileSettings.Data.m_eCharPoolUsage, 'DarkSoldier');
		//CharacterGenerator = `XCOMGRI.Spawn(NewSoldierState.GetMyTemplate().CharacterGeneratorClass);
		//`assert(CharacterGenerator != none);

		NewSoldierState.RandomizeStats();
		NewSoldierState.ApplyInventoryLoadout(StartState);

		InfoState = XComGameState_Unit_DarkXComInfo(StartState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo'));
		InfoState.InitComponent(SelectNextSoldierClass(), NewSoldierState.GetReference().ObjectID);
		//NewSoldierState.AddComponentObject(InfoState);
		StartState.AddStateObject(InfoState);


		if(InfoState.GetClassName() == 'DarkReclaimed') //handling for Reclaimed: they should look like Skirmishers
			class'UnitDarkXComUtils'.static.DoReclaimedAppearance(StartState, NewSoldierState);

		if((ResHQ.NumMonths / BaseMonthsForRanks) > 1)
		{
		AdditionalRanks = (ResHQ.NumMonths / BaseMonthsForRanks);
		AdditionalRanks = Clamp(AdditionalRanks, 1, 3); //clamping because shit gets stupid past a certain rank
		InfoState.RankUp(AdditionalRanks);

		}

		DarkXComHQ.AddToCrew(StartState, NewSoldierState);
		//NewSoldierState.m_RecruitDate = GameTime.CurrentTime; // AddToCrew does this, but during start state creation the StrategyRuleset hasn't been created yet

		StartState.AddStateObject( NewSoldierState );
	}

}
//------------------------------------------------------------OTHER CREW FUNCTIONS
function RenewPCSes(XComGameState NewGameState)
{
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_Unit					 Unit;
	local int i;

	for(i = 0; i < Crew.Length; i++)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		if(Unit == none)
		{
			`log("Dark XCom: Could not find valid unit.", ,'DarkXCom');
			continue;
		}

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState == none)
			`log("Dark XCom: could not find infostate for unit.", ,'DarkXCom');


		if(InfoState != none)
		{
		NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
		NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.bIsAlive)
			{
			`log("Dark XCom: re-rolling PCS for Genetic PCS Dark Event", ,'DarkXCom');
			NewInfoState.SetPCS(class'UnitDarkXComUtils'.static.GetAllDarkPCS(NewInfoState));
			}
		}
	}
}
//---------------------------------------------------------------------------------------
function BuildSoldierClassDeck()
{
	local X2DarkSoldierClassTemplate SoldierClassTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2DataTemplate Template;
	local SoldierClassCount ClassCount;
	local int i;
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	if (SoldierClassDeck.Length != 0)
	{
		SoldierClassDeck.Length = 0;
	}


	foreach TemplateManager.IterateTemplates(Template, none)
	{
		SoldierClassTemplate = X2DarkSoldierClassTemplate(Template);
		if(SoldierClassTemplate != none)
		{
			for(i = 0; i < SoldierClassTemplate.NumInDeck; ++i)
			{
				SoldierClassDeck.AddItem(SoldierClassTemplate.DataName);
				if(SoldierClassDistribution.Find('SoldierClassName', SoldierClassTemplate.DataName) == INDEX_NONE)
				{
					// Add to array to track class distribution
					ClassCount.SoldierClassName = SoldierClassTemplate.DataName;
					ClassCount.Count = 0;
					SoldierClassDistribution.AddItem(ClassCount);
				}
			}
		}

	}

}

//---------------------------------------------------------------------------------------
function name SelectNextSoldierClass(optional name ForcedClass)
{
	local name RetName;
	local array<name> ValidClasses;
	local int Index;

	if(SoldierClassDeck.Length == 0)
	{
		BuildSoldierClassDeck();
	}
	
	if(ForcedClass != '')
	{
		// Must be a valid class in the distribution list
		if(SoldierClassDistribution.Find('SoldierClassName', ForcedClass) != INDEX_NONE)
		{
			// If not in the class deck rebuild the class deck
			if(SoldierClassDeck.Find(ForcedClass) == INDEX_NONE)
			{
				BuildSoldierClassDeck();
			}

			ValidClasses.AddItem(ForcedClass);
		}
	}

	// Only do this if not forced
	if(ValidClasses.Length == 0)
	{
		ValidClasses = GetValidNextSoldierClasses();
	}
	
	// If not forced, and no valid, rebuild
	if(ValidClasses.Length == 0)
	{
		BuildSoldierClassDeck();
		ValidClasses = GetValidNextSoldierClasses();
	}

	if(SoldierClassDeck.Length == 0)
		`RedScreen("No elements found in SoldierClassDeck array. This might break class assignment, please inform realitymachina and provide a save.");

	if(ValidClasses.Length == 0)
		`RedScreen("No elements found in ValidClasses array. This might break class assignment, please inform realitymachina and provide a save.");
	
	RetName = ValidClasses[`SYNC_RAND(ValidClasses.Length)];
	`log("Chosen class is " $ RetName, ,'DarkXCom');
	SoldierClassDeck.Remove(SoldierClassDeck.Find(RetName), 1);
	Index = SoldierClassDistribution.Find('SoldierClassName', RetName);
	SoldierClassDistribution[Index].Count++;

	return RetName;
}

//---------------------------------------------------------------------------------------
private function int GetClassDistributionDifference(name SoldierClassName)
{
	local int LowestCount, ClassCount, idx;

	LowestCount = SoldierClassDistribution[0].Count;

	for(idx = 0; idx < SoldierClassDistribution.Length; idx++)
	{
		if(SoldierClassDistribution[idx].Count < LowestCount)
		{
			LowestCount = SoldierClassDistribution[idx].Count;
		}

		if(SoldierClassDistribution[idx].SoldierClassName == SoldierClassName)
		{
			ClassCount = SoldierClassDistribution[idx].Count;
		}
	}

	return (ClassCount - LowestCount);
}


//---------------------------------------------------------------------------------------
function array<name> GetValidNextSoldierClasses()
{
	local array<name> ValidClasses;
	local int idx;

	for(idx = 0; idx < SoldierClassDeck.Length; idx++)
	{
		if(GetClassDistributionDifference(SoldierClassDeck[idx]) < 1)
		{
			ValidClasses.AddItem(SoldierClassDeck[idx]);
		}
	}

	return ValidClasses;
}


//---------------------------------------------------------------------------------------
function array<name> GetNeededSoldierClasses()
{
	local XComGameStateHistory History;
	local array<SoldierClassCount> ClassCounts, ClassHighestRank;
	local SoldierClassCount SoldierClassStruct, EmptyStruct;
	local XComGameState_Unit UnitState;
	local array<name> NeededClasses;
	local int idx, Index, HighestClassCount;

	History = `XCOMHISTORY;

	// Grab reward classes
	for(idx = 0; idx < SoldierClassDistribution.Length; idx++)
	{
		SoldierClassStruct = EmptyStruct;
		SoldierClassStruct.SoldierClassName = SoldierClassDistribution[idx].SoldierClassName;
		SoldierClassStruct.Count = 0;
		ClassCounts.AddItem(SoldierClassStruct);
		ClassHighestRank.AddItem(SoldierClassStruct);
	}

	HighestClassCount = 0;

	// Grab current crew information
	for(idx = 0; idx < Crew.Length; idx++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(Crew[idx].ObjectID));

		if(UnitState != none)
		{
			Index = ClassCounts.Find('SoldierClassName', UnitState.GetSoldierClassTemplate().DataName);

			if(Index != INDEX_NONE)
			{
				// Add to class count
				ClassCounts[Index].Count++;
				if(ClassCounts[Index].Count > HighestClassCount)
				{
					HighestClassCount = ClassCounts[Index].Count;
				}

				// Update Highest class rank if applicable
				if(ClassHighestRank[Index].Count < UnitState.GetRank())
				{
					ClassHighestRank[Index].Count = UnitState.GetRank();
				}
			}
		}
	}

	// Parse the info to grab needed classes
	for(idx = 0; idx < ClassCounts.Length; idx++)
	{
		if((ClassCounts[idx].Count == 0) || ((HighestClassCount - ClassCounts[idx].Count) >= 2) || ((HighestSoldierRank - ClassHighestRank[idx].Count) >= 2))
		{
			NeededClasses.AddItem(ClassCounts[idx].SoldierClassName);
		}
	}

	// If no classes are needed, all classes are needed
	if(NeededClasses.Length == 0)
	{
		for(idx = 0; idx < ClassCounts.Length; idx++)
		{
			NeededClasses.AddItem(ClassCounts[idx].SoldierClassName);
		}
	}

	return NeededClasses;
}

function AddToCrew(XComGameState NewGameState, XComGameState_Unit NewUnit )
{
	Crew.AddItem(NewUnit.GetReference());
}


function RemoveFromCrew( StateObjectReference CrewRef )
{
	Crew.RemoveItem(CrewRef);
}
//--------------------------------------------------------------------------------------
// CHANCE TO ROLL
//---------------------------------------------------------------------------------------
function int HandleChance()
{
	ChanceToRoll = (MissingChance * NumSinceAppearance) + BaseChance;
	
	return ChanceToRoll;
}

//--------------------------------------------------------------------------------------
// PRE MISSION UPDATE
//---------------------------------------------------------------------------------------
static function PreMissionUpdate(XComGameState NewGameState, XComGameState_MissionSite MissionState, bool IsPlotMission)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCOM DarkXComHQ;

	switch (MissionState.GeneratedMission.Mission.sType)
	{
		case "GP_Broadcast":
		case "GP_FortressLeadup":
		case "ChosenStrongholdShort":
		case "ChosenStrongholdLong":
		case "Sabotage":
		case "LostAndAbandonedA":
		case "LostAndAbandonedB":
		case "LostAndAbandonedC":
		case "CompoundRescueOperative":
		case "CovertEscape":
		case "LastGift":
		case "LastGiftB":
		case "LastGiftC":
		case "AlienNest":
			`log("DLC or special mission detected. Aborting.", ,'DarkXCom');
			return;
		default:
			break;
	}

		//



	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHq.ObjectID));
	//NewGameState.AddStateObject(DarkXComHQ);


	if(!IsPlotMission || (IsPlotMission && MissionState.GeneratedMission.Mission.sType == "Dark_OffsiteStorage")) //off site storage is defended by regular ADVENT augmented by a permanent MOCX attachment
	{
		DarkXComHQ.FillSquad(NewGameState);
		If(DarkXComHQ.GetCurrentSquadSize() > 0) 
		{
			if(IsPlotMission)
			{
				DarkXComHQ.UpdateSpawningData(NewGameState, MissionState, IsPlotMission); // MOCX spawns in story missions normally, comes in as reinforcements otherwise
			}
			DarkXComHQ.NumSinceAppearance = 0;
		}
		else
		{
			DarkXComHQ.NumSinceAppearance += 1;
		}
	}

	if(IsPlotMission && MissionState.GeneratedMission.Mission.sType == "Dark_TrainingRaid")
	{
		DarkXComHQ.FillSquad(NewGameState);
		If(DarkXComHQ.GetCurrentSquadSize() > 0)
		{
			DarkXComHQ.UpdateSpawningData(NewGameState, MissionState, IsPlotMission);
		}
		else
		{
			DarkXComHQ.NumSinceAppearance += 1;
		}

	}

	if(IsPlotMission && MissionState.GeneratedMission.Mission.sType == "Dark_RooftopsAssault")
	{
		DarkXComHQ.SpawnSquad(NewGameState, MissionState); //three squads to patrol HQ alongside ADVENT base security
		DarkXComHQ.SpawnSquad(NewGameState, MissionState);
		DarkXComHQ.SpawnSquad(NewGameState, MissionState);
	}

}

function int GetCurrentSquadSize()
{

	return Squad.Length;
}

function FillSquad(XcomGameState NewGameState)
{
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_Unit					 Unit;
	local int i;

	Squad.Length = 0;
	for(i = 0; i < Crew.Length; i++)
	{
		if(Squad.Length >= GetMaxSquadSize())
		{
			`log("Dark XCom: Finished making squad.", ,'DarkXCom');
			break;
		}

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		if(Unit == none)
		{
			`log("Dark XCom: Could not find valid unit.", ,'DarkXCom');
			continue;
		}

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState == none)
			`log("Dark XCom: could not find infostate for unit.", ,'DarkXCom');


		if(InfoState != none)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.bIsAlive && NewInfoState.GetRecoveryPoints() <= 0 && !NewInfoState.bInSquad) //is alive and is done healing
			{
				`log("Added following MOCX soldier to squad: " $ class'UnitDarkXComUtils'.static.GetFullName(Unit), ,'DarkXCom');
				Squad.AddItem(Crew[i]);
				NewInfoState.bInSquad = true;
				NewInfoState.bAlreadyHandled = false;
				NewInfoState.AssignedUnit.ObjectID = -1;
			}
		}

	}
}


function int GetMaxSquadSize()
{
	local int i;

	i = StartingSquadSize;

	if(bSquadSizeI)
	{
		i += 1;
	}

	if(bSquadSizeII)
	{
		i += 1;
	}

	return i;
}

//---------------------------------------------------------------------------------------
function UpdateSpawningData(XComGameState NewGameState, XComGameState_MissionSite MissionState, bool IsPlotMission)
{
	local X2SelectedEncounterData NewEncounter, EmptyEncounter;
	local XComTacticalMissionManager TacticalMissionManager;
	local PrePlacedEncounterPair EncounterInfo;
	local array<X2CharacterTemplate> SelectedCharacterTemplates;
	local ConfigurableEncounter Encounter;
	local float AlienLeaderWeight, AlienFollowerWeight;
	local XComAISpawnManager SpawnManager;
	local int LeaderForceLevelMod, i;
	local MissionSchedule SelectedMissionSchedule;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local array<Name> NamesToAdd;
	local float AlongLOP, FromLOP;
	local int RebellionChance;
	local int iNumSld;
	local string strTechTierSuffix;
	local X2StrategyElementTemplateManager StgrMgr;
	local CHXComGameVersionTemplate VersionCheck;
	StgrMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	VersionCheck = CHXComGameVersionTemplate(StgrMgr.FindStrategyElementTemplate('CHXComGameVersion'));



	iNumSld = Clamp(GetMaxSquadSize(), 2, 10);
	EncounterInfo.EncounterID = name("MOCX_Teamx" $ iNumSld);


/*
	EncounterInfo.EncounterID='MOCX_Teamx4';

	if(Squad.Length <= 2)
		EncounterInfo.EncounterID='MOCX_Teamx2';

	if(Squad.Length == 3)
		EncounterInfo.EncounterID='MOCX_Teamx3';

	if(Squad.Length == 5)
		EncounterInfo.EncounterID='MOCX_Teamx5';

	if(Squad.Length == 6)
		EncounterInfo.EncounterID='MOCX_Teamx6';

	if(Squad.Length == 7)
		EncounterInfo.EncounterID='MOCX_Teamx7';

	if(Squad.Length >= 8)
		EncounterInfo.EncounterID='MOCX_Teamx8';

	if(Squad.Length == 9)
		EncounterInfo.EncounterID='MOCX_Teamx9';

	if(Squad.Length >= 10)
		EncounterInfo.EncounterID='MOCX_Teamx10';
*/

	AlongLOP = `SYNC_RAND(25) - `SYNC_RAND(15);
	AlongLOP = min(25, AlongLOP);
	FromLOP = `SYNC_RAND(25) - `SYNC_RAND(15) - 5;
	if(!ManualEncounterZone)
	{
		EncounterInfo.EncounterZoneOffsetAlongLOP = AlongLOP; //randomized locations
		EncounterInfo.EncounterZoneOffsetFromLOP = FromLOP;
		EncounterInfo.EncounterZoneWidth = 50;
		EncounterInfo.EncounterZoneDepthOverride = 20;
	}
	else
	{
		EncounterInfo.EncounterZoneOffsetAlongLOP = configAlongLOP; //randomized locations
		EncounterInfo.EncounterZoneOffsetFromLOP = configFromLOP;
		EncounterInfo.EncounterZoneWidth = configEncounterZoneWidth;
		EncounterInfo.EncounterZoneDepthOverride = configEncounterZoneDepthOverride;
	}

	TacticalMissionManager = `TACTICALMISSIONMGR;
	SpawnManager = `SPAWNMGR;
	AlienLeaderWeight = 0.0;
	AlienFollowerWeight = 0.0;

	//TacticalMissionManager.GetConfigurableEncounter( EncounterInfo.EncounterID, Encounter, MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel );
	Encounter.EncounterID = EncounterInfo.EncounterID;
	Encounter.MaxSpawnCount = GetMaxSquadSize();

	if(bAdvancedMECs)
	{
		i = `SYNC_RAND(100);
		if(i <= AdvancedMECChance)
		{
			NamesToAdd.AddItem('AdvMec_MOCX');
		}

	}
	strTechTierSuffix = GetTierSuffixFromTech();
	`log("Dark XCom: we are at tier " $ strTechTierSuffix, ,'DarkXCom');
	for(i = 0; i < GetCurrentSquadSize(); i++)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
		// mocx soldier templates upgrade their equipment via tech
		NamesToAdd.AddItem(name(InfoState.GetClassName() $ strTechTierSuffix));
	}
/*
	if(!bHasCoil)
	{
		for(i = 0; i < GetCurrentSquadSize(); i++)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(InfoState.GetClassName());
		}
	}

	if(bHasCoil && !bHasPlasma)
	{
		for(i = 0; i < GetCurrentSquadSize(); i++)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M2"));
		}
	}

	if(bHasPlasma)
	{
		for(i = 0; i < GetCurrentSquadSize(); i++)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M3"));
		}
	}

*/
	if(NamesToAdd.Length < GetMaxSquadSize())
	{
		for(i = NamesToAdd.Length; i < GetMaxSquadSize(); i++)
		{
			if(MissionState.SelectedMissionData.ForceLevel < 9)
				NamesToAdd.AddItem('DarkRookie'); //spawning rookies to fill in gaps

			if(MissionState.SelectedMissionData.ForceLevel < 15 && MissionState.SelectedMissionData.ForceLevel > 9)
				NamesToAdd.AddItem('DarkRookie_M2'); //spawning rookies to fill in gaps

			if(MissionState.SelectedMissionData.ForceLevel >= 15)
				NamesToAdd.AddItem('DarkRookie_M3'); //spawning rookies to fill in gaps

		}

	}

	Encounter.ForceSpawnTemplateNames = NamesToAdd;

	if(VersionCheck.GetVersionNumber() >= ((1 * 100000000) + (10 * 10000))) //is 1.10
	{
		if(default.RebelChance > 0 && !IsPlotMission){
			RebellionChance = `SYNC_RAND(100);

			if(RebellionChance < default.RebelChance){
				Encounter.TeamToSpawnInto = eTeam_One; //rebellion team
			}
			else{
				Encounter.TeamToSpawnInto = eTeam_Alien; //loyalist team
			}
		}
	}
	else{
		Encounter.TeamToSpawnInto = eTeam_Alien;
	}
	Encounter.ReinforcementCountdown = 1;

	TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);

	if( MissionState.SelectedMissionData.SelectedMissionScheduleName == '' )
	{
		`log("Dark XCOM: we were somehow given a missionstate with no schedule: fix it ourselves", , 'DarkXCom');
		MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
		MissionState.UpdateSelectedMissionData();
		TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);
	}

	NewEncounter = EmptyEncounter;

	`log("Dark XCom: Current Encounter ID is " $ Encounter.EncounterID, ,'DarkXCom');

	NewEncounter.SelectedEncounterName = Encounter.EncounterID;
	LeaderForceLevelMod = SpawnManager.GetLeaderForceLevelMod();

	// select the group members who will fill out this encounter group
	AlienLeaderWeight += SelectedMissionSchedule.AlienToAdventLeaderRatio;
	AlienFollowerWeight += SelectedMissionSchedule.AlienToAdventFollowerRatio;
	SpawnManager.SelectSpawnGroup(NewEncounter.EncounterSpawnInfo, MissionState.GeneratedMission.Mission, SelectedMissionSchedule, MissionState.GeneratedMission.Sitreps, Encounter ,MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel, SelectedCharacterTemplates, AlienLeaderWeight, AlienFollowerWeight, LeaderForceLevelMod);

	//NewEncounter.EncounterSpawnInfo.SelectedCharacterTemplateNames = NamesToAdd;
	NewEncounter.EncounterSpawnInfo.EncounterZoneWidth = EncounterInfo.EncounterZoneWidth;
	NewEncounter.EncounterSpawnInfo.EncounterZoneDepth = ((EncounterInfo.EncounterZoneDepthOverride >= 0.0) ? EncounterInfo.EncounterZoneDepthOverride : SelectedMissionSchedule.EncounterZonePatrolDepth);
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetFromLOP = EncounterInfo.EncounterZoneOffsetFromLOP;
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetAlongLOP = EncounterInfo.EncounterZoneOffsetAlongLOP;

	NewEncounter.EncounterSpawnInfo.SpawnLocationActorTag = EncounterInfo.SpawnLocationActorTag;

	MissionState.SelectedMissionData.SelectedEncounters.AddItem(NewEncounter);

}



//---------------------------------------------------------------------------------------
// GRAND FINALE
//-----------------------------------
function SpawnSquad(XComGameState NewGameState, XComGameState_MissionSite MissionState, optional bool HasBossSpawn)
{
	local X2SelectedEncounterData NewEncounter, EmptyEncounter;
	local XComTacticalMissionManager TacticalMissionManager;
	local PrePlacedEncounterPair EncounterInfo;
	local array<X2CharacterTemplate> SelectedCharacterTemplates;
	local ConfigurableEncounter Encounter;
	local float AlienLeaderWeight, AlienFollowerWeight;
	local XComAISpawnManager SpawnManager;
	local int LeaderForceLevelMod, i;
	local MissionSchedule SelectedMissionSchedule;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local array<Name> NamesToAdd;
	local float AlongLOP, FromLOP;
	local array<XComGameState_Unit> CurrentSquad;

	local int iNumSld;
	local string strTechTierSuffix;

	iNumSld = Clamp(GetMaxSquadSize(), 2, 10);
	EncounterInfo.EncounterID = name("MOCX_Teamx" $ iNumSld);

/*	EncounterInfo.EncounterID='MOCX_Teamx4';

	if(GetMaxSquadSize() <= 2)
		EncounterInfo.EncounterID='MOCX_Teamx2';

	if(GetMaxSquadSize() == 3)
		EncounterInfo.EncounterID='MOCX_Teamx3';

	if(GetMaxSquadSize()== 5)
		EncounterInfo.EncounterID='MOCX_Teamx5';

	if(GetMaxSquadSize() == 6)
		EncounterInfo.EncounterID='MOCX_Teamx6';

	if(GetMaxSquadSize() == 7)
		EncounterInfo.EncounterID='MOCX_Teamx7';

	if(GetMaxSquadSize() >= 8)
		EncounterInfo.EncounterID='MOCX_Teamx8';

	if(GetMaxSquadSize() == 9)
		EncounterInfo.EncounterID='MOCX_Teamx9';

	if(GetMaxSquadSize() >= 10)
		EncounterInfo.EncounterID='MOCX_Teamx10';*/


	AlongLOP = `SYNC_RAND(25) - `SYNC_RAND(15) + 5;
	FromLOP = `SYNC_RAND(25) - `SYNC_RAND(15) - 5;
	if(!ManualEncounterZone)
	{
		EncounterInfo.EncounterZoneOffsetAlongLOP = AlongLOP; //randomized locations
		EncounterInfo.EncounterZoneOffsetFromLOP = FromLOP;
		EncounterInfo.EncounterZoneWidth = 50;
		EncounterInfo.EncounterZoneDepthOverride = 20;
	}
	else
	{
		EncounterInfo.EncounterZoneOffsetAlongLOP = configAlongLOP; //randomized locations
		EncounterInfo.EncounterZoneOffsetFromLOP = configFromLOP;
		EncounterInfo.EncounterZoneWidth = configEncounterZoneWidth;
		EncounterInfo.EncounterZoneDepthOverride = configEncounterZoneDepthOverride;
	}


	TacticalMissionManager = `TACTICALMISSIONMGR;
	SpawnManager = `SPAWNMGR;
	AlienLeaderWeight = 0.0;
	AlienFollowerWeight = 0.0;

	//TacticalMissionManager.GetConfigurableEncounter( EncounterInfo.EncounterID, Encounter, MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel );
	Encounter.EncounterID = EncounterInfo.EncounterID;

	CurrentSquad = GetFirstAvailableCrew(NewGameState);
	Encounter.MaxSpawnCount = CurrentSquad.Length;


	if(bAdvancedMECs)
	{
		i = `SYNC_RAND(100);
		if(i < AdvancedMECChance)
		{
			NamesToAdd.AddItem('AdvMec_MOCX');
		}
	}

	if(HasBossSpawn)
	{
		NamesToAdd.AddItem('MOCX_Leader');
	}
	strTechTierSuffix = GetTierSuffixFromTech();
	`log("Dark XCom: we are at tier " $ strTechTierSuffix, ,'DarkXCom');
	for(i = 0; i < CurrentSquad.Length; i++)
	{
		Unit = CurrentSquad[i];
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
		// mocx soldier templates upgrade their equipment via tech
		NamesToAdd.AddItem(name(InfoState.GetClassName() $ strTechTierSuffix));
	}
/*	if(!bHasCoil)
	{
		for(i = 0; i < CurrentSquad.Length; i++)
		{
			Unit = CurrentSquad[i];
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(InfoState.GetClassName());
		}
	}

	if(bHasCoil && !bHasPlasma)
	{
		for(i = 0; i < CurrentSquad.Length; i++)
		{
			Unit = CurrentSquad[i];
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M2"));
		}
	}

	if(bHasPlasma)
	{
		for(i = 0; i < CurrentSquad.Length; i++)
		{
			Unit = CurrentSquad[i];
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M3"));
		}
	}*/

	Encounter.ForceSpawnTemplateNames = NamesToAdd;
	Encounter.TeamToSpawnInto = eTeam_Alien;
	Encounter.ReinforcementCountdown = 1;

	TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);

	if( MissionState.SelectedMissionData.SelectedMissionScheduleName == '' )
	{
		`log("Dark XCOM: we were somehow given a missionstate with no schedule: fix it ourselves", , 'DarkXCom');
		MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
		MissionState.UpdateSelectedMissionData();
		TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);
	}
	NewEncounter = EmptyEncounter;

	`log("Dark XCom: Current Encounter ID is " $ Encounter.EncounterID, ,'DarkXCom');

	NewEncounter.SelectedEncounterName = Encounter.EncounterID;
	LeaderForceLevelMod = SpawnManager.GetLeaderForceLevelMod();

	// select the group members who will fill out this encounter group
	AlienLeaderWeight += SelectedMissionSchedule.AlienToAdventLeaderRatio;
	AlienFollowerWeight += SelectedMissionSchedule.AlienToAdventFollowerRatio;
	SpawnManager.SelectSpawnGroup(NewEncounter.EncounterSpawnInfo, MissionState.GeneratedMission.Mission, SelectedMissionSchedule, MissionState.GeneratedMission.Sitreps, Encounter ,MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel, SelectedCharacterTemplates, AlienLeaderWeight, AlienFollowerWeight, LeaderForceLevelMod);

	//NewEncounter.EncounterSpawnInfo.SelectedCharacterTemplateNames = NamesToAdd;
	NewEncounter.EncounterSpawnInfo.EncounterZoneWidth = EncounterInfo.EncounterZoneWidth;
	NewEncounter.EncounterSpawnInfo.EncounterZoneDepth = ((EncounterInfo.EncounterZoneDepthOverride >= 0.0) ? EncounterInfo.EncounterZoneDepthOverride : SelectedMissionSchedule.EncounterZonePatrolDepth);
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetFromLOP = EncounterInfo.EncounterZoneOffsetFromLOP;
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetAlongLOP = EncounterInfo.EncounterZoneOffsetAlongLOP;

	NewEncounter.EncounterSpawnInfo.SpawnLocationActorTag = EncounterInfo.SpawnLocationActorTag;

	MissionState.SelectedMissionData.SelectedEncounters.AddItem(NewEncounter);

}

function string GetTierSuffixFromTech()
{
	if (bHasPlasma)
		return "_M3";
	else if (bHasCoil)
		return "_M2";
	else
		return "";
}


function array<XComGameState_Unit> GetFirstAvailableCrew(XcomGameState NewGameState)
{
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_Unit					Unit;
	local array<XComGameState_Unit> ArrayToSend;
	local int i;

	for(i = 0; i < Crew.Length; i++)
	{
		if(ArrayToSend.Length >= 4)
		{
			`log("Dark XCom: Finished making squad.", ,'DarkXCom');
			break;
		}

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		if(Unit == none)
		{
			`log("Dark XCom: Could not find valid unit.", ,'DarkXCom');
			continue;
		}

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState == none)
			`log("Dark XCom: could not find infostate for unit.", ,'DarkXCom');


		if(InfoState != none)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.bIsAlive && !NewInfoState.bInSquad) //is alive and is done healing
			{
			`log("Added following MOCX soldier to squad: " $ class'UnitDarkXComUtils'.static.GetFullName(Unit), ,'DarkXCom');
				ArrayToSend.AddItem(Unit);
				NewInfoState.bInSquad = true;
				Squad.AddItem(Crew[i]);
			}
		}

	}

	return ArrayToSend;
}