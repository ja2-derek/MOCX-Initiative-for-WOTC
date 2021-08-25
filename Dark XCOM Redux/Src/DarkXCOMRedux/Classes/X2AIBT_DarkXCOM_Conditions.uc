// Additional Behavior Tree conditions for Dark XCOM
class X2AIBT_DarkXCOM_Conditions extends X2AIBTDefaultConditions config(DarkXCom);

var config float InjuryEvacLimit;

static event bool FindBTConditionDelegate(name strName, optional out delegate<BTConditionDelegate> dOutFn, optional out Name NameParam)
{
	dOutFn = None;

	if(ParseNameForNameAbilitySplit(strName, "UnitTemplateIs-", NameParam))
	{
		dOutFn = IsUnitTemplate;
		return true;
	}


	switch( strName )
	{
		case 'HasRifle':
			dOutFn = HasRifleWeapon;
			return true;
			break;

		case 'HasShotgun':
			dOutFn = HasShotgunWeapon;
			return true;
			break;

		case 'HasCannon':
			dOutFn = HasCannonWeapon;
			return true;
		break;

		case 'HasSniperRifle':
			dOutFn = HasSniperWeapon;
			return true;
		break;

		case 'HasLauncher':
			dOutFn = HasGrenadeWeapon;
			return true;
		break;
		
		case 'HasGremlin':
			dOutFn = HasGremlinWeapon;
			return true;

		case 'HasPistol':
			dOutFn = HasPistolWeapon;
			return true;
		break;

		case 'HasTargeter':
			dOutFn = HasHoloWeapon;
			return true;
		break;

		case 'HasSword':
			dOutFn = HasSwordWeapon;
			return true;
		break;

		case 'HasKnife':
			dOutFn = HasKnifeWeapon;
			return true;
		break;

		case 'HasGauntlet':
			dOutFn = HasGauntletWeapon;
			return true;
		break;

		case 'HasStunner':
			dOutFn = HasStunWeapon;
			return true;

		case 'ShouldRequestEvac':
			dOutFn = ShouldRequestEvac;
			return true;
			break;
		break;

		default:
		break;
	}

	return super.FindBTConditionDelegate(strName, dOutFn, NameParam);
}

function bt_status IsUnitTemplate()
{
	local XComGameState_Unit UnitState;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	if(UnitState.GetMyTemplateName() == SplitNameParam)
		return BTS_SUCCESS;

	`LogAIBT("IsUnitTemplate FAILED: unit template was not " $ SplitNameParam, ,'DarkXCom');

	return BTS_FAILURE;
}

function bt_status HasRifleWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'rifle')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasShotgunWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'shotgun')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status HasCannonWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'cannon')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasSniperWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'sniper_rifle')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasGrenadeWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'grenade_launcher')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasGremlinWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'gremlin')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status HasPistolWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'pistol')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasHoloWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'holotargeter')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasSwordWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'sword')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasKnifeWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'combatknife')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasGauntletWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'gauntlet')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status HasStunWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'arcthrower')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status ShouldRequestEvac()
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
	UnitState = m_kUnitState;
	//if(UnitState.GetMyTemplateGroupName() != 'DarkXComSoldier')
	//{
		//UnitState = XComGameState_Unit(kTarget);
	//}
	if(UnitState.GetMyTemplateGroupName() != 'DarkXComSoldier')
	{
		return BTS_FAILURE;
	}
	CanEvac = false;
	if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXAssault') //no evaccing on story missions
		return BTS_FAILURE;
	//if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXTraining')
		//return 'AA_UnitIsImmune';
//
	//if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXOffsite') 
		//return 'AA_UnitIsImmune';
	if (UnitState == none)
		return BTS_FAILURE;
	if(UnitState.bRemovedFromPlay || ((!UnitState.IsAbleToAct() || UnitState.ActionPoints.Length < 1) && !UnitState.IsBleedingOut()) ) //already evacuated or is stunned in some way, that isn't them bleeding out
		return BTS_FAILURE;
	if ((UnitState.IsDead() || UnitState.IsUnconscious()) && !UnitState.IsBleedingOut() )
		return BTS_FAILURE;
	if (UnitState.IsPanicked() && !UnitState.IsBleedingOut())
		return BTS_FAILURE;
		
	if(UnitState.GetCurrentStat(eStat_AlertLevel) != `ALERT_LEVEL_RED)
	{
		//`log("Dark XCOM: " $ UnitState.GetFullName() $ " is not yet alerted to be able to consider evacuating");
		return BTS_FAILURE;
	}
	//  Check to see if we are eligible to evac
	MaxHP = UnitState.GetMaxStat(eStat_HP);
	CurrentHP = UnitState.GetCurrentStat(eStat_HP);
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
					//`log("Dark XCOM: counting " $ OtherUnit.GetFullName() $ " as bleeding out or already evacuating for the purposes of Dark Evac");
					DeadCount++;
				}
				else if (OtherUnit.bRemovedFromPlay )
				{
					//`log("Dark XCOM: counting " $ OtherUnit.GetFullName() $ " as removed from play for the purposes of Dark Evac");
					DeadCount++;
				}
				else if(OtherUnit.IsUnconscious())
				{
					//`log("Dark XCOM: counting " $ OtherUnit.GetFullName() $ " as KO'd for the purposes of Dark Evac");
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
		//`log("Dark XCOM: with a starting squad of " $ OriginalCount $ " that has lost over " $ DeadCount $ " squad members, we are leaving.");
		CanEvac = true;
	}
	else if(DeadCount > 0) // otherwise, roll against their will with a malus against the dead
	{
		//`log("Dark XCOM: with a starting squad of " $ OriginalCount $ " that has lost over " $ DeadCount $ " squad members, we are CONSIDERING leaving.");
		Will = UnitState.GetCurrentStat(eStat_Will) - (10 * DeadCount);
		Will += 40; // buff to accoutn for lower will - this is apparently much lower at colonel level or so than I Thought?
		if(`SYNC_RAND_STATIC(100) > Will)
		{
			//`log("Dark XCOM: our will (+ the base bonus of 40) was " $ Will $ " but we are now leaving.");
			CanEvac = true;
		}
	}
	if(CurrentHP < MaxHP && !CanEvac)
	{
	//`log("Dark XCom: Checking HP For Evac");
		if(CurrentHP == 1)
		{
			CanEvac = true; //they're about to die, evac
			//`log("Dark XCOM: due to current health being " $ CurrentHP $ " unit is about to die and is leaving");
		}
		else if((CurrentHP / MaxHP) <= InjuryEvacLimit) //if at or under 40% of HP, can evac
		{
			//`log("Dark XCOM: due to current health being " $ CurrentHP $ " while max health is " $ MaxHP $ ", we are now considering evacuating");
			//`log("Dark XCOM: We being " $ UnitState.GetFullName() );
			Will = UnitState.GetCurrentStat(eStat_Will) /*- (5 * (MaxHP - CurrentHP))*/;
			if(`SYNC_RAND_STATIC(100) > Will)
			{
				//`log("Dark XCOM: our will was " $ Will $ " but we are now leaving.");
				CanEvac = true;
			}
		}
		else
		{
			//`log("Dark XCOM: health at " $ CurrentHP $ " while max health is " $ MaxHP $ ", it's above the limit of "$InjuryEvacLimit);
		}
	}
	if (CanEvac)
	{
		//`log("Dark XCom: we can evacuate now");
		return BTS_SUCCESS;
	}
	return BTS_FAILURE;
}