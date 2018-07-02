
class UIScreenListener_DarkEvents extends UIScreenListener;
// This event is triggered after a screen is initialized
simulated function OnInit(UIScreen Screen)
{

	if(UIMission(Screen) != none)
	{
		if(UIMission_GOps(Screen) != none) //support for GOps: we grab the array of missions and throw in everything
		{
			RollForSITREP(Screen, true);
		}
		else
		{
			RollForSITREP(Screen, false);
		}
	}
}

// This event is triggered after a screen receives focus
simulated function OnReceiveFocus(UIScreen Screen)
{

	if(UIMission(Screen) != none)
	{
		if(UIMission_GOps(Screen) != none) //support for GOps: we grab the array of missions and throw in everything
		{
			RollForSITREP(Screen, true);
		}
		else
		{
			RollForSITREP(Screen, false);
		}
	}
}

function bool IsInvalidScreen(UIScreen Screen)
{
	if(UIMission_MOCXPath(Screen) != none || UIMission_ChosenAmbush(Screen) != none || UIMission_AlienFacility(Screen) != none)
		return true;

	if(UIMission_GoldenPath(Screen) != none || UIMission_ChosenStronghold(Screen) != none || UIMission_GPIntelOptions(Screen) != none)
		return true;

	if(UIMission_RescueSoldier(Screen) != none)
		return true;

	return false;
}

function RollForSitrep(UIScreen Screen, bool IsGOps)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local int RandomRoll;
	local XComGameState NewGameState;
	//local GeneratedMissionData MissionData;
	local XComGameState_HeadquartersXCom	XComHQ; //because the game stores a copy of mission data and this is where its stored in

	if(IsInvalidScreen(Screen))
		return;

	History = class'XComGameStateHistory'.static.GetGameStateHistory();

	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	If((DarkXComHQ.bSITREPActive && DarkXComHQ.HandleChance() < 200 && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive() )|| ( !DarkXComHQ.bIsActive && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive() ) || (DarkXComHQ.bIsDestroyed && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive()))
		return;

	RandomRoll = `SYNC_RAND_STATIC(100);
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("UIMission: Adding MOCX Related Tag");
	if(!IsGOps)
	{
		
		ModifyOtherMission(RandomRoll, XComHQ, DarkXComHQ, Screen, NewGameState);
	}
	else
	{
		ModifyGuerillaMissions(XComHQ, DarkXComHQ, Screen, NewGameState);
	}

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		`log("Dark XCom: updated mission(s) being looked at with SITREP.", , 'DarkXCom');
		if(UIMission_GOps(Screen) != none)
		{
			UIMission_GOps(Screen).UpdateData();
		}
		else if(UIMission(Screen) != none)
		{
			UIMission(Screen).UpdateData();
		}
	}
	else if(NewGameState != none)
	{
		History.CleanupPendingGameState(NewGameState);
	}
}
function ModifyGuerillaMissions(XComGameState_HeadquartersXCom XComHQ, XComGameState_HeadquartersDarkXCom DarkXComHQ, UIScreen Screen, XComGameState NewGameState)
{
	local array<XComGameState_MissionSite> MissionStates;
	local XComGameState_MissionSite MissionState;
	local int RandomRoll;
	MissionStates = UIMission_GOps(Screen).arrMissions;

	foreach MissionStates(MissionState)
	{
		RandomRoll = `SYNC_RAND(100);
		if(RandomRoll <= DarkXComHQ.HandleChance() && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive() && !DarkXComHQ.bSITREPActive)
		{

			if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE && MissionState.TacticalGameplayTags.Find('SITREP_MOCX') != INDEX_NONE)
			{
				return;
			}

			if(class'UnitDarkXComUtils'.static.HasContestingTags(MissionState))
			{
				return;
			}

			if(class'UnitDarkXComUtils'.static.IsInvalidMission(MissionState.GetMissionSource()))
			{
				return;
			}
			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

			`log("Dark XCom: current mission source being looked at is " $ MissionState.GetMissionSource().DataName, ,'DarkXCom');
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			MissionState.GeneratedMission.Sitreps.AddItem('MOCX');
			MissionState.TacticalGameplayTags.AddItem('SITREP_MOCX');
			DarkXComHQ.bSITREPActive = true;

			ModifyMissionData(XComHQ, MissionState);

		}

		if(class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive())
		{

			MissionState = UIMission(Screen).GetMission();
			if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE)
			{
				return;
			}

			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

			`log("Dark XCom: current mission source being looked at is " $ MissionState.GetMissionSource().DataName, ,'DarkXCom');
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			MissionState.GeneratedMission.Sitreps.AddItem('MOCX');
			MissionState.TacticalGameplayTags.AddItem('SITREP_MOCX');

			ModifyMissionData(XComHQ, MissionState);

		}

		if(DarkXComHQ.bSITREPActive || (RandomRoll > DarkXComHQ.HandleChance() && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive())) //no cheat and roll failed, so mark this mission as having no MOCX
		{
			MissionState = UIMission(Screen).GetMission();
			if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE)
			{
				return;
			}
			if(MissionState.TacticalGameplayTags.Find('NoMOCX') != INDEX_NONE)
				return;

			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

			`log("Dark XCom: current mission source being looked at is " $ MissionState.GetMissionSource().DataName, ,'DarkXCom');
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			MissionState.TacticalGameplayTags.AddItem('NoMOCX');

			ModifyMissionData(XComHQ, MissionState);
		}
	}
}
//
function ModifyOtherMission(int RandomRoll, XComGameState_HeadquartersXCom XComHQ, XComGameState_HeadquartersDarkXCom DarkXComHQ, UIScreen Screen, XComGameState NewGameState)
{
		local XComGameState_MissionSite MissionState;
		if(RandomRoll <= DarkXComHQ.HandleChance() && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive())
		{

			MissionState = UIMission(Screen).GetMission();
			if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE && MissionState.TacticalGameplayTags.Find('SITREP_MOCX') != INDEX_NONE)
			{
				return;
			}

			if(class'UnitDarkXComUtils'.static.HasContestingTags(MissionState))
			{
				return;
			}

			if(class'UnitDarkXComUtils'.static.IsInvalidMission(MissionState.GetMissionSource()))
			{
				return;
			}
			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

			`log("Dark XCom: current mission source being looked at is " $ MissionState.GetMissionSource().DataName, ,'DarkXCom');
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			MissionState.GeneratedMission.Sitreps.AddItem('MOCX');
			MissionState.TacticalGameplayTags.AddItem('SITREP_MOCX');
			DarkXComHQ.bSITREPActive = true;

			ModifyMissionData(XComHQ, MissionState);

		}

		if(class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive())
		{

			MissionState = UIMission(Screen).GetMission();
			if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE)
			{
				return;
			}

			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

			`log("Dark XCom: current mission source being looked at is " $ MissionState.GetMissionSource().DataName, ,'DarkXCom');
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			MissionState.GeneratedMission.Sitreps.AddItem('MOCX');
			MissionState.TacticalGameplayTags.AddItem('SITREP_MOCX');

			ModifyMissionData(XComHQ, MissionState);

		}

		if(RandomRoll > DarkXComHQ.HandleChance() && !class'X2DownloadableContentInfo_DarkXCOMRedux'.static.IsCheatActive()) //no cheat and roll failed, so mark this mission as having no MOCX
		{
			MissionState = UIMission(Screen).GetMission();
			if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE)
			{
				return;
			}

			if(MissionState.TacticalGameplayTags.Find('NoMOCX') != INDEX_NONE)
				return;

			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

			`log("Dark XCom: current mission source being looked at is " $ MissionState.GetMissionSource().DataName, ,'DarkXCom');
			MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

			MissionState.TacticalGameplayTags.AddItem('NoMOCX');

			ModifyMissionData(XComHQ, MissionState);
		}
}

//---------------------------------------------------------------------------------------
function ModifyMissionData(XComGameState_HeadquartersXCom XComHQ, XComGameState_MissionSite MissionState)
{
	local int MissionDataIndex;

	MissionDataIndex = XComHQ.arrGeneratedMissionData.Find('MissionID', MissionState.GetReference().ObjectID);

	if(MissionDataIndex != INDEX_NONE)
	{
		XComHQ.arrGeneratedMissionData[MissionDataIndex] = MissionState.GeneratedMission;
	}
}


defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}