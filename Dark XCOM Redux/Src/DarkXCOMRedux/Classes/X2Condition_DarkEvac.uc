class X2Condition_DarkEvac extends X2Condition config(DarkXCom);

var config float InjuryEvacLimit;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit UnitState, OtherUnit;
	local array<XComGameState_Unit> AllUnits;
	//local XComGameState_Effect EffectState;
	local int DeadCount, OriginalCount;
	local float CurrentHP, MaxHP, Will;
	local bool CanEvac;
	local XGBattle_SP Battle;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSite;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionSite = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));
	UnitState = XComGameState_Unit(kSource);

	if(UnitState.GetMyTemplateGroupName() != 'DarkXComSoldier')
	{
		UnitState = XComGameState_Unit(kTarget);
	}
	if(UnitState.GetMyTemplateGroupName() != 'DarkXComSoldier')
	{
		return 'AA_UnitIsImmune';
	}
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
		
	if(UnitState.GetCurrentStat(eStat_AlertLevel) != `ALERT_LEVEL_RED)
	{
		//`log("Dark XCOM: " $ UnitState.GetFullName() $ " is not yet alerted to be able to consider evacuating");
		return 'AA_UnitIsImmune';
	}

	//  Check to see if we are eligible to evac

	MaxHP = UnitState.GetMaxStat(eStat_HP);
	CurrentHP = UnitState.GetCurrentStat(eStat_HP);




	//if (!CanEvac) //now we start checking if half the squad is dead or already away
//	{
	//`log("Dark XCom: Checking Squad For Evac");
		DeadCount = 0;
		OriginalCount = 1; //well I mean if we can check this...
		Battle = XGBattle_SP(`BATTLE);

		// CHECKING in case we're using rebellious mocx
		if(Battle != none)
		{
			if(UnitState.GetTeam() == eTeam_Alien)
			{
				Battle.GetAIPlayer().GetOriginalUnits(AllUnits, true, true);
			}
			else
			{
				class'CHHelpers'.static.GetTeamOnePlayer().GetOriginalUnits(AllUnits, true, true);
			}
			foreach AllUnits(OtherUnit)
			{
				if(otherUnit.GetMyTemplateName() == 'DarkRookie' || otherUnit.GetMyTemplateName() == 'DarkRookie_M2' || otherUnit.GetMyTemplateName() == 'DarkRookie_M3'
					|| otherUnit.GetMyTemplateName() == 'DarkSoldier' ){
					continue; //skip rookies and our strategy unit states
				}

				if (OtherUnit.GetReference() != UnitState.GetReference() && OtherUnit.GetMyTemplate().CharacterGroupName == 'DarkXComSoldier')
				{
					OriginalCount++;

					if(OtherUnit.IsDead())
					{
						DeadCount++;
					}
					else if((OtherUnit.IsBleedingOut() && OtherUnit.GetCurrentStat(eStat_HP) == 1))
					{
						//adding an explicit check here for the unit being at 1 HP to double check if they're actually bleeding out 
					//	`log("Dark XCOM: counting " $ OtherUnit.GetFullName() $ " as bleeding out or already evacuating for the purposes of Dark Evac");
						DeadCount++;
					}
					else if (OtherUnit.bRemovedFromPlay )
					{
					//	`log("Dark XCOM: counting " $ OtherUnit.GetFullName() $ " as removed from play for the purposes of Dark Evac");
						DeadCount++;
					}
					else if(OtherUnit.IsUnconscious())
					{
					//	`log("Dark XCOM: counting " $ OtherUnit.GetFullName() $ " as KO'd for the purposes of Dark Evac");
						DeadCount++;
					}
				}
			}
		}
		if(DeadCount == 0) // do not divide by zero
		{
			CanEvac = false;
		}
		else if((OriginalCount / DeadCount) < 2) //always evac if we lost over half the squad
		{
			`log("Dark XCOM: with a starting squad of " $ OriginalCount $ " that has lost over " $ DeadCount $ " squad members, we are leaving.");
			CanEvac = true;
		}
		else if(DeadCount > 0) // otherwise, roll against their will with a malus against the dead
		{
			`log("Dark XCOM: with a starting squad of " $ OriginalCount $ " that has lost over " $ DeadCount $ " squad members, we are CONSIDERING leaving.");
			Will = UnitState.GetCurrentStat(eStat_Will) - (10 * DeadCount);
			Will += 40; // buff to accoutn for lower will - this is apparently much lower at colonel level or so than I Thought?
			if(`SYNC_RAND_STATIC(100) > Will)
			{
				`log("Dark XCOM: our will (+ the base bonus of 40) was " $ Will $ " but we are now leaving.");
				CanEvac = true;
			}
		}

//	}

	if(CurrentHP < MaxHP && !CanEvac)
	{
	//`log("Dark XCom: Checking HP For Evac");
		if(CurrentHP == 1)
		{
			CanEvac = true; //they're about to die, evac
		}
		else if((CurrentHP / MaxHP) <= default.InjuryEvacLimit) //if at or under 40% of HP, can evac
		{
			`log("Dark XCOM: due to current health being " $ CurrentHP $ " while max health is " $ MaxHP $ ", we are now considering evacuating");
			`log("We being " $ UnitState.GetFullName() );
			Will = UnitState.GetCurrentStat(eStat_Will) - (5 * (MaxHP - CurrentHP));
			if(`SYNC_RAND_STATIC(100) > Will)
			{
				CanEvac = true;
			}
		}
	}

	if (CanEvac)
	{
		//`log("Dark XCom: we can evacuate now");
		return 'AA_Success';
	}

	return 'AA_UnitIsImmune';
}