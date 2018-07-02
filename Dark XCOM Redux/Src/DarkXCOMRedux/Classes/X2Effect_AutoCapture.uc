///---------------------------------------------------------------------------------------
//  FILE:    X2Effect_SmartMacrophages
//  AUTHOR:  Amineri (Long War Studios), modified by Realitymachina
//  PURPOSE: Implements effect for SmartMacrophages ability -- this allows healing of lowest hp at end of mission
//			similar to SmartMacrophages, but applies only to self, and always works (unless dead), and is independent of Field Surgeon
//--------------------------------------------------------------------------------------- 
//---------------------------------------------------------------------------------------
class X2Effect_AutoCapture extends X2Effect_Persistent;


function UnitEndedTacticalPlay(XComGameState_Effect EffectState, XComGameState_Unit UnitState)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		SourceUnitState; 
	local XComGameState				NewGameState;
	History = `XCOMHISTORY;
	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));


	if(!AutoCapturedEffectIsValidForSource(SourceUnitState)) { return; }

	if(!CanBeCaptured(UnitState)) { return; }

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating unit");
	UnitState.bBodyRecovered = true;
	UnitState.EvacuateUnit(NewGameState); //with bBodyRecovered = true, we give the enemy unit to XCOM
	`GAMERULES.SubmitGameState(NewGameState);
	super.UnitEndedTacticalPlay(EffectState, UnitState);
}

function bool CanBeCaptured(XComGameState_Unit UnitState)
{
   local XComGameStateHistory History;
   local XComGameState_BattleData BattleData;

   History = `XCOMHISTORY;
   BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

   return BattleData.AllTacticalObjectivesCompleted();  //check for mission completion
}

function bool AutoCapturedEffectIsValidForSource(XComGameState_Unit SourceUnit)
{
	if(SourceUnit == none) { return false; } //don't fire if there's nothing
	if(!SourceUnit.IsBleedingOut() && !SourceUnit.IsUnconscious()) { return false; } //don't fire if the unit's concious: they would've been picked up by something else
	if(SourceUnit.LowestHP == 0) { return false; } //this means they're dead
	if(SourceUnit.bBodyRecovered){return false;} //this means they were already captured
	//if(SourceUnit.bRemovedFromPlay){return false;}
	return true;
}

DefaultProperties
{
	EffectName="AutoCaptureMOCX"
	DuplicateResponse=eDupe_Ignore
}