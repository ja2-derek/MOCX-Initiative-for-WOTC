class X2Condition_DarkEvac extends X2Condition config(DarkXCom);

var config float InjuryEvacLimit;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit UnitState, OtherUnit;
	local array<XComGameState_Unit> AllUnits;
	//local XComGameState_Effect EffectState;
	local int DeadCount, OriginalCount;
	local float CurrentHP, MaxHP;
	local bool CanEvac;
	local XGBattle_SP Battle;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSite;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionSite = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));
	UnitState = XComGameState_Unit(kSource);
	CanEvac = false;

	if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXAssault') //no evaccing on story missions
		return 'AA_UnitIsImmune';

	//if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXTraining')
		//return 'AA_UnitIsImmune';
//
	//if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXOffsite') 
		//return 'AA_UnitIsImmune';

	if (UnitState == none)
		return 'AA_NotAUnit';

	if(UnitState.bRemovedFromPlay || ((!UnitState.IsAbleToAct() || UnitState.ActionPoints.Length < 1) && !UnitState.IsBleedingOut()) ) //already evacuated or is stunned in some way, that isn't them bleeding out
		return 'AA_UnitIsImmune';

	if ((UnitState.IsDead() || UnitState.IsUnconscious()) && !UnitState.IsBleedingOut() )
		return 'AA_UnitIsDead';

	if (UnitState.IsPanicked() && !UnitState.IsBleedingOut())
		return 'AA_UnitIsPanicked';


	//  Check to see if we are eligible to evac

	MaxHP = UnitState.GetBaseStat(eStat_HP);
	CurrentHP = UnitState.GetCurrentStat(eStat_HP);


	if(CurrentHP < MaxHP)
	{
	//`log("Dark XCom: Checking HP For Evac");
		if((CurrentHP / MaxHP) <= default.InjuryEvacLimit) //if at or under 40% of HP, can evac
			CanEvac = true;

	}

	if (CanEvac) //now we start checking if half the squad is dead or already away
	{
	//`log("Dark XCom: Checking Squad For Evac");
		DeadCount = 0;
		OriginalCount = 1; //well I mean if we can check this...
		Battle = XGBattle_SP(`BATTLE);
		if(Battle != none)
			Battle.GetAIPlayer().GetOriginalUnits(AllUnits, true, true);

		foreach AllUnits(OtherUnit)
		{
			if(otherUnit.GetMyTemplateName() == 'DarkRookie' || otherUnit.GetMyTemplateName() == 'DarkRookie_M2' || otherUnit.GetMyTemplateName() == 'DarkRookie_M3'){
				continue; //skip rookies
			}

			if (OtherUnit != UnitState && OtherUnit.GetMyTemplate().CharacterGroupName == 'DarkXComSoldier')
			{
				OriginalCount++;

				if(OtherUnit.IsDead())
				{
					DeadCount++;
				}
				else if(OtherUnit.IsBleedingOut() || OtherUnit.bRemovedFromPlay || OtherUnit.IsUnitAffectedByEffectName('RM_Escaping'))
				{
					DeadCount++;
				}
				else if(OtherUnit.IsUnconscious())
				{
					DeadCount++;
				}
			}
		}

		if(DeadCount > 0 && (OriginalCount / DeadCount < 2)) //less than 2 so odd numbered squads have to lose a majority to evac
			CanEvac = true;

	}

	if (CanEvac)
	{
		//`log("Dark XCom: we can evacuate now");
		return 'AA_Success';
	}

	return 'AA_UnitIsImmune';
}