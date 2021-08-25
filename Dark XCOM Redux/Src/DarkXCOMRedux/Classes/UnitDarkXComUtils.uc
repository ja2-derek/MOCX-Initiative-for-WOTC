class UnitDarkXComUtils extends Object config(DarkXCom);

var config int NormalHealingRate;

var config int AdvancedHealingRate;

var config array<name> NormalPCSes;
var config array<name> GenePCSes;

var config array<SoldierClassAbilityType> AWCAbilities;

var config int AWCLimit; //how many AWC abilities can a MOCX soldier have?

var config int RankPenalty;
var config int InjuryBonus;

static function bool CombatUnitAlreadyUsed(XComGameState_HeadquartersDarkXCom DarkXComHQ, int ObjectID)
{
	local XComGameState_Unit_DarkXComInfo InfoState;
	local array<StateObjectReference> Squad;
	local XComGameState_Unit CurrentDarkUnit;
	local XComGameStateHistory History;
	local int i;
	Squad = DarkXCOmHq.Squad;
	History = `XCOMHistory;
	for(i = 0; i < DarkXComHQ.Squad.Length; i++)
	{
			CurrentDarkUnit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(CurrentDarkUnit);
			if(InfoState != none)
			{
				if(InfoState.AssignedUnit.ObjectID == ObjectID)
				{
					return true;
				}
			}
	}

	return false;
}
static function bool AlreadySpawnedSquad(XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local XComGameState_Unit_DarkXComInfo InfoState;
	local XComGameSTate_Unit CurrentDarkUnit;
	local array<StateObjectReference> Squad;
	local XcomGameStateHistory History;
	local int i;
	History = `XCOMHistory;
	if(DarkXCOMHq.Squad.Length > 0)
	{
		for(i = 0; i < DarkXComHQ.Squad.Length; i++)
		{
			CurrentDarkUnit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(CurrentDarkUnit);
			if(InfoState != none && !InfoState.bAlreadyHandled)
			{
				//`log(CurrentDarkUnit.GetFullName() $ " with the class " $ InfoState.GetClassName() $ " isn't spawned in by the game yet.", ,'DarkXCom');
				return false; // this squad has yet to have a combat unit attached to it, we didn't spawn people at the start here
			}
		}

		return true; // everybody meant to be here already is on the mission, ignore our check
	}
	return false; // no squad is meant to be on this mission
}
// this is for getting dark skrimisher character templates that may exist in the pool
static function array<XComGameState_Unit> GetSkirmCharPoolCandidates(X2CharacterTemplate Template)
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;
	local array<XComGameState_Unit> CharacterPool, Candidates;
	
	Candidates.Length = 0; //remove stale data

	if(none == Template) {
		return Candidates;
	}

	if(Template.DataName == 'DarkRookie' || Template.DataName == 'DarkRookie_M2' || Template.DataName == 'DarkRookie_M3'){
		return Candidates;
	}

	History = `XCOMHISTORY;
	CharacterPool = `CHARACTERPOOLMGR.CharacterPool;


	for(i = 0; i < CharacterPool.length; ++i)
	{
		if(class'XGCharacterGenerator_DarkXCom'.static.Filter(CharacterPool[i], Template))
		{
			Candidates.AddItem(CharacterPool[i]);
		}
	}

	// skip history check
	if(Candidates.length == 0) return Candidates;

	// remove characters who have already appeared this campaign
	foreach History.IterateByClassType(class'XComGameState_Unit', Unit)
	{
		if(class'UnitDarkXComUtils'.static.GetFullName(Unit) == "") 
			continue;

		//`log("Dark XCom: Unit being checked for cloning is " $ class'UnitDarkXComUtils'.static.GetFullName(Unit));

		if(Unit.GetMyTemplateName() != 'SkirmisherSoldier' && Unit.GetMyTemplateName() != 'DarkSoldier') 
		{
			if(Candidates[i].GetName(eNameType_FullNick) == class'UnitDarkXComUtils'.static.GetFullName(Unit))
			{
				Candidates.Remove(i, 1); // auto remove non-skrimishers
				--i;
			}
		}

		for(i = 0; i < Candidates.length; ++i)
		{	
			//so what we're doing here is comparing every unit made in the game so far to the candidates we have in the Character Pool. 
			//we remove candidates from consideration IF they've already been used by the game, whether for XCOM, as a Dark VIP, or for MOCX alerady.

			if(Candidates[i].GetName(eNameType_FullNick) == class'UnitDarkXComUtils'.static.GetFullName(Unit) && (Unit.GetMyTemplateName() != 'DarkSoldier' || (Unit.GetMyTemplateName() == 'DarkSoldier' && Template.DataName == 'DarkSoldier')))
			{
				//explanation: if this is for a tactical proxy, do not remove the strategic characters from consideration. If this is for a strategic character, then act as normal
				Candidates.Remove(i, 1);
				--i;
			}
		}
	}

	return Candidates;
}

static function DoReclaimedAppearance(XComGameState NewGameState, out XComGameState_Unit UnitState)
{
	local XComGameState_Unit SkirmState, Unit;
	local array<XComGameState_Unit> Characters;
	local X2CharacterTemplate CharTemplate;
	local XGCharacterGenerator CharacterGenerator;
	local TSoldier SkirmAppearance;
	local int FirstNameMLength, FirstNameFLength, LastNameLength;
	local string FirstName, LastName, Nickname;
	local bool FoundCandidate;

	FoundCandidate = false;
	Characters = GetSkirmCharPoolCandidates(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('DarkSoldier'));	
	CharTemplate = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('SkirmisherSoldier');
	if(Characters.Length > 0)
	{
		// pick one at random
		Unit = Characters[`SYNC_RAND_STATIC(Characters.Length)];
		CharacterGenerator = `XCOMGRI.Spawn(CharTemplate.CharacterGeneratorClass);
		SkirmAppearance = CharacterGenerator.CreateTSoldierFromUnit(Unit, NewGameState);
		CharacterGenerator.Destroy(); //destroy the generator so it doesn't take up memory more than it needs to

		UnitState.kAppearance.nmVoice = SkirmAppearance.kAppearance.nmVoice;
		UnitState.kAppearance.nmHead = SkirmAppearance.kAppearance.nmHead;
		UnitState.kAppearance.nmHaircut = SkirmAppearance.kAppearance.nmHaircut;
		UnitState.kAppearance.iHairColor = SkirmAppearance.kAppearance.iHairColor;
		UnitState.kAppearance.nmVoice = SkirmAppearance.kAppearance.nmVoice;
		UnitState.kAppearance.nmBeard = SkirmAppearance.kAppearance.nmBeard;
		UnitState.kAppearance.iRace = SkirmAppearance.kAppearance.iRace;
		UnitState.kAppearance.nmScars = SkirmAppearance.kAppearance.nmScars;
		UnitState.kAppearance.iGender = SkirmAppearance.kAppearance.iGender;
		UnitState.SetUnitName(Unit.GetFirstName(), UNit.GetLastName(), Unit.GetNickname());
		
		SkirmAppearance.kAppearance = UnitState.kAppearance;

		UnitState.SetTAppearance(SkirmAppearance.kAppearance); //this should sync the appearance with any potential new gender)
	}


	if(!FoundCandidate)
	{
		FirstNameMLength = class'X2StrategyElement_XpackCountries'.default.m_arrSkMFirstNames.Length;
		FirstNameFLength = class'X2StrategyElement_XpackCountries'.default.m_arrSkFFirstNames.Length;
		LastNameLength = class'X2StrategyElement_XpackCountries'.default.m_arrSkLastNames.Length;

		
		CharacterGenerator = `XCOMGRI.Spawn(CharTemplate.CharacterGeneratorClass);
		SkirmState = CharTemplate.CreateInstanceFromTemplate(NewGameState);
		SkirmState.kAppearance.iGender = UnitState.kAppearance.iGender; //this gives us an appearance to sync with the unit we have
		SkirmAppearance = CharacterGenerator.CreateTSoldierFromUnit(SkirmState, NewGameState);
		CharacterGenerator.Destroy(); //destroy the generator so it doesn't take up memory more than it needs to

		UnitState.kAppearance.nmVoice = SkirmAppearance.kAppearance.nmVoice;
		UnitState.kAppearance.nmHead = SkirmAppearance.kAppearance.nmHead;
		UnitState.kAppearance.nmHaircut = SkirmAppearance.kAppearance.nmHaircut;
		UnitState.kAppearance.iHairColor = SkirmAppearance.kAppearance.iHairColor;
		UnitState.kAppearance.nmVoice = SkirmAppearance.kAppearance.nmVoice;
		UnitState.kAppearance.nmBeard = SkirmAppearance.kAppearance.nmBeard;
		UnitState.kAppearance.iRace = SkirmAppearance.kAppearance.iRace;
		UnitState.kAppearance.nmScars = SkirmAppearance.kAppearance.nmScars;


		FirstName = UnitState.kAppearance.iGender == eGender_Female ? class'X2StrategyElement_XpackCountries'.default.m_arrSkMFirstNames[`SYNC_RAND_STATIC(FirstNameMLength)] :  class'X2StrategyElement_XpackCountries'.default.m_arrSkFFirstNames[`SYNC_RAND_STATIC(FirstNameFLength)];
		LastName = class'X2StrategyElement_XpackCountries'.default.m_arrSkLastNames[`SYNC_RAND_STATIC(LastNameLength)];

		NickName = UnitState.GetNickName();
		UnitState.SetUnitName(Firstname, LastName, NickName);
	}
}

static function BuyPsiAbility(XComGameState_Unit UnitState, XComGameState NewGameState, XComGameState_Unit_DarkXComInfo InfoState)
{
	local SCATProgression ProgressAbility;
	local X2AbilityTemplate AbilityTemplate;
	local name AbilityName;
	local SoldierClassAbilityType MOCXAbility;
	local int iName;
	local bool CanAddFromInfo;
	
	CanAddFromInfo = false;

	foreach InfoState.SoldierAbilities(MOCXAbility)
	{
		AbilityName = MOCXAbility.AbilityName;

		if(MOCXAbility.AbilityName == 'HolyWarriorM3')
			AbilityName = 'Solace';

		if(MOCXAbility.AbilityName == 'PsiMindControl')
			AbilityName = 'Domination';

		if(UnitState.HasSoldierAbility(AbilityName))
			continue; //skip if we already have it

		ProgressAbility = UnitState.GetSCATProgressionForAbility(AbilityName);

		if(ProgressAbility.iRank == INDEX_NONE || ProgressAbility.iBranch == INDEX_NONE) //we got an invalid ability, SKIP
			continue;

		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);
		if (AbilityTemplate != none)
		{
			// Check to make sure that soldier has any prereq abilites required, and if not then add the prereq ability instead
			if (AbilityTemplate.PrerequisiteAbilities.Length > 0)
			{
				for (iName = 0; iName < AbilityTemplate.PrerequisiteAbilities.Length; iName++)
				{
					AbilityName = AbilityTemplate.PrerequisiteAbilities[iName];
					if (!UnitState.HasSoldierAbility(AbilityName)) // if the soldier does not have the prereq ability, replace it
					{
						AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);
						ProgressAbility = UnitState.GetSCATProgressionForAbility(AbilityName);
						break;
					}
				}
			}						
		}

		CanAddFromInfo = true; //we got one from the infostate

		UnitState.BuySoldierProgressionAbility(NewGameState, ProgressAbility.iRank, ProgressAbility.iBranch);
		break;
	}


	// Teach the soldier their next psi ability
	if(!CanAddFromInfo)
	{
		foreach UnitState.PsiAbilities(ProgressAbility)
		{
			AbilityName = UnitState.GetAbilityName(ProgressAbility.iRank, ProgressAbility.iBranch);
			if (AbilityName != '' && !UnitState.HasSoldierAbility(AbilityName))
			{
				AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);
				if (AbilityTemplate != none)
				{
					// Check to make sure that soldier has any prereq abilites required, and if not then add the prereq ability instead
					if (AbilityTemplate.PrerequisiteAbilities.Length > 0)
					{
						for (iName = 0; iName < AbilityTemplate.PrerequisiteAbilities.Length; iName++)
						{
							AbilityName = AbilityTemplate.PrerequisiteAbilities[iName];
							if (!UnitState.HasSoldierAbility(AbilityName)) // if the soldier does not have the prereq ability, replace it
							{
								AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);
								ProgressAbility = UnitState.GetSCATProgressionForAbility(AbilityName);
								break;
							}
						}
					}						
				}

				UnitState.BuySoldierProgressionAbility(NewGameState, ProgressAbility.iRank, ProgressAbility.iBranch);
				break;
			}
		}
	}

}
static function GiveSoldierToXCOM(XComGameState_Unit MissionUnitState, XComGameState_Unit_DarkXComInfo InfoState, XComGameState NewGameState)
{
	local XComGameStateHistory History; 
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	local X2CharacterTemplateManager CharTemplateMgr;
	local X2CharacterTemplate CharacterTemplate;
    local XComGameState_Unit UnitState;
	local int idx, NewRank, StartingIdx;
	local XComGameState_Item WeaponState;
	local name UnitClass, DarkClass;
	local X2DarkSoldierClassTemplate MOCXTemplate;
	local X2SoldierClassTemplate ClassTemplate;
	local name TemplarPawn;
	History = `XCOMHistory;
	CharTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	CharacterTemplate = CharTemplateMgr.FindCharacterTemplate('Soldier'); //we know all soldiers we'll be getting are human only...
	MOCXTemplate = class'UnitDarkXComUtils'.static.FindDarkClassTemplate(InfoState.GetClassName());
	TemplarPawn = '';
	if(MOCXTemplate.CounterpartClass.Length > 1)
	{
		DarkClass = MOCXTemplate.CounterpartClass[`SYNC_RAND_STATIC(MOCXTemplate.CounterpartClass.Length)]; // pick a random class
	}
	else
	{
		DarkClass = MOCXTemplate.CounterpartClass[0]; // pick just the first class 
	}
	ClassTemplate = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager().FindSoldierClassTemplate(DarkClass);

	if(InfoState.GetClassName() == 'DarkReclaimed' )
		CharacterTemplate = CharTemplateMgr.FindCharacterTemplate('SkirmisherSoldier'); //unless it's a reclaimed

	if(InfoState.GetClassName() == 'DarkZealot' )
		CharacterTemplate = CharTemplateMgr.FindCharacterTemplate('TemplarSoldier'); // TODO: FIX THIS - this really should be modular instead of requiring hardcoding

	If(ClassTemplate.DataName == 'Reaper')
		CharacterTemplate = CharTemplateMgr.FindCharacterTemplate('ReaperSoldier');


	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	// Create the new unit and make sure she has the best gear available (will also update to appropriate armor customizations)
	UnitState = CharacterTemplate.CreateInstanceFromTemplate(NewGameState);

	if(InfoState.GetClassName() == 'DarkZealot')
	{
		TemplarPawn = UnitState.kAppearance.nmPawn;
	}

	// set appearance first before we do anything else
	UnitState.SetTAppearance(MissionUnitState.kAppearance);

	if(TemplarPawn != '')
	{
		UnitState.kAppearance.nmPawn = TemplarPawn;
	}
	UnitState.SetCharacterName(MissionUnitState.GetFirstName(), MissionUnitState.GetLastName(), MissionUnitState.GetNickName());
	UnitState.ApplyInventoryLoadout(NewGameState);
	NewRank = InfoState.GetRank();
	UnitState.SetXPForRank(NewRank);
	UnitState.StartingRank = NewRank;
	StartingIdx = 0;
	UnitClass = '';
	if(UnitState.GetMyTemplate().DefaultSoldierClass != '' && UnitState.GetMyTemplate().DefaultSoldierClass != class'X2SoldierClassTemplateManager'.default.DefaultSoldierClass)
	{
		// Some character classes start at squaddie on creation
		StartingIdx = 1;
	}

	if(ClassTemplate != none)
	{
	
			`log("We found a working counterpart class for " $ MOCXTemplate.DataName $ " , which is " $ ClassTemplate.DataName , ,'DarkXCom');
			UnitClass = ClassTemplate.DataName; //we don't need to do this for skirmishers since they already start at squaddie

	}

	if(ClassTemplate.DataName != 'PsiOperative' && ClassTemplate.NumInDeck < 1 && ClassTemplate.NumInForcedDeck < 1) // invalid class
	{
		//we assume psi operatives are always valid since no mod dummies them out
		// we allow usage of classes meant to be trainable only since MOCX may have a counterpart class
		// we do the same for classes meant to be random/reward only since again, MOCX may have a counterpart class
		// if neither are true, remove the class name;
		`log("Unfortuantely, this class is invalid as a counterpart to MOCX: " $ ClassTemplate.DataName , ,'DarkXCom');
		UnitClass = '';
	}
	for (idx = StartingIdx; idx < NewRank; idx++)
	{
		
		// Rank up to squaddie
		if (idx == 0)
		{
			if(UnitClass == '')
			{
				UnitState.RankUpSoldier(NewGameState, ResistanceHQ.SelectNextSoldierClass());
				`log("No valid counterpart class, so we are instead using" $ UnitState.GetSoldierClassTemplateName() , ,'DarkXCom');
			}
			if(UnitClass != '')
			{
				UnitState.RankUpSoldier(NewGameState, UnitClass);
			}
			UnitState.ApplySquaddieLoadout(NewGameState);
			UnitState.bNeedsNewClassPopup = false;

			if(UnitClass == 'PsiOperative') //ok, we need to do some more complicated logic here  since psi ops don't gain abilities the normal way
				BuyPsiAbility(UnitState, NewGameState, InfoState);
		}
		else
		{
			UnitState.RankUpSoldier(NewGameState, UnitState.GetSoldierClassTemplate().DataName);

			if(UnitClass == 'PsiOperative') //ok, we need to do some more complicated logic here  since psi ops don't gain abilities the normal way
				BuyPsiAbility(UnitState, NewGameState, InfoState);
		}
	}
	UnitState.ApplyBestGearLoadout(NewGameState);
	UnitState.SetStatus(eStatus_Active);
	UnitState.bNeedsNewClassPopup = false;

	UnitState.SetCountry(MissionUnitState.GetCountry());
	MissionUnitState.GenerateBackground(); 
	UnitState.SetBackground(MissionUnitState.GetBackground());

	// Make sure that primary and secondary weapon appearances match
	WeaponState = UnitState.GetPrimaryWeapon();
	WeaponState.WeaponAppearance = MissionUnitState.GetPrimaryWeapon().WeaponAppearance;
	WeaponState = UnitState.GetSecondaryWeapon();
	WeaponState.WeaponAppearance = MissionUnitState.GetSecondaryWeapon().WeaponAppearance;

	XComHQ.AddToCrew(NewGameState, UnitState);
	UnitState.SetCurrentStat(eStat_Will, MissionUnitState.GetCurrentStat(eStat_Will));
	UnitState.SetCurrentStat(eStat_HP, MissionUnitState.GetCurrentStat(eStat_HP));
	//UnitState.AddXp(MissionUnitState.GetXPValue() - UnitState.GetXPValue());
	//UnitState.CopyKills(MissionUnitState);
	//UnitState.CopyKillAssists(MissionUnitState);
	UnitState.LowestHP = MissionUnitState.LowestHP;
	UnitState.HighestHP = MissionUnitState.HighestHP;
	UnitState.bRankedUp = false;
//
	//if(UnitState.IsInjured() && UnitState.GetStatus() != eStatus_Healing)
	//{
		//HealProjectState = XComGameState_HeadquartersProjectHealSoldier(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectHealSoldier'));
		//HealProjectState.SetProjectFocus(UnitState.GetReference(), NewGameState);
		//XComHQ.Projects.AddItem(HealProjectState.GetReference());
		//UnitState.SetStatus(eStatus_Healing);
	//}
//


}

static function bool WasCaptureSuccessful(XComGameState_Unit_DarkXComInfo InfoState, int LostHP, bool WasMindControlled)
{
	local int CaptureChance, CapturePenalty, Roll;

	if(InfoState.bRecruited || InfoState.bRolledForCapture)
		return InfoState.bRecruited; //is either true or false

	CaptureChance = 100;

	CapturePenalty = 0;

	CapturePenalty = (default.RankPenalty * InfoState.GetRank());
		
	CaptureChance -= CapturePenalty;

	CaptureChance += (default.InjuryBonus * LostHP);

	if(CaptureChance <= 0)
		CaptureChance = 1; //pity percent

	if(WasMindControlled)
	{
		CaptureChance *= 2; //double for MC'd MOCX.
	}
	`log("Capture Chance for MOCX unit is " $ CaptureChance, , 'DarkXCom');
	Roll = `SYNC_RAND_STATIC(100);

	if(Roll < CaptureChance)
	{
		InfoState.bRecruited = true;
		InfoState.bRolledForCapture = true;
		return true;
	}
	InfoState.bRolledForCapture = true;

	return false;
}

static function string GetFullName(XComGameState_Unit Unit)
{
	local bool bFirstNameBlank;

	bFirstNameBlank = (Unit.GetFirstName() == "");

	if(bFirstNameBlank)
		return (SanitizeQuotes(Unit.GetNickName())  @ Unit.GetLastName());

	return (Unit.GetFirstName() @ SanitizeQuotes(Unit.GetNickName())  @  Unit.GetLastName());

}

static function string SanitizeQuotes(string DisplayLabel)
{
	local string SanitizedLabel; 

	SanitizedLabel = DisplayLabel; 

	//If we're in CHT, check to see if we spot single quotes in the name. If so, strip them out. 
	if( GetLanguage() == "CHT" )
	{
		if( Left(SanitizedLabel, 1) == "'" )
		{
			SanitizedLabel = Right(SanitizedLabel, Len(SanitizedLabel) - 1);
		}
		if( Right(SanitizedLabel, 1) == "'" )
		{
			SanitizedLabel = Left(SanitizedLabel, Len(SanitizedLabel) - 1);
		}
	}
	return SanitizedLabel; 
}



static function RemoveFromSquad(XComGameState_HeadquartersDarkXCom DarkXComHQ, StateObjectReference ReferenceToRemove, XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	DarkXComHQ.Squad.RemoveItem(ReferenceToRemove);
	DarkInfoState.bInSquad = false;
	DarkInfoState.bCosmeticDone = false;

	If(!DarkInfoState.bIsAlive)
	{
		`log("Dark XCOM: Soldier has died, removing from HQ's active crew.", ,'DarkXCom');
		DarkXComHq.DeadCrew.AddItem(ReferenceToRemove);
		DarkXComHQ.Crew.RemoveItem(ReferenceToRemove);
	}

}


static function KillDarkSoldier(XComGameState_Unit_DarkXComInfo DarkInfoState, optional bool WasCaptured)
{
	DarkInfoState.bIsAlive = false;

	if(WasCaptured)
		DarkInfoState.bWasCaptured = true;
}

static function bool IsAlive(XComGameState_Unit Unit )
{
	local XComGameState_Unit_DarkXComInfo InfoState;

	if (Unit != none)
	{
		InfoState = GetDarkXComComponent(Unit);

		return InfoState.bIsAlive;
	}
	return false;
}

static function bool WasCaptured(XComGameState_Unit Unit )
{
	local XComGameState_Unit_DarkXComInfo InfoState;

	if (Unit != none)
	{
		InfoState = GetDarkXComComponent(Unit);

		return InfoState.bWasCaptured;
	}
	return false;
}

static function GiveAWCAbility(XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	local array<name> ValidAbilities, CurrentAbilities, ExcludedAbilities, SoldierAbilities;
	local name AbilityToSend;
	local int i, k;
	local SoldierClassAbilityType CurrentAbility;
	local X2DarkSoldierClassTemplate Template;


	Template = class'UnitDarkXComUtils'.static.FindDarkClassTemplate(DarkInfoState.GetClassName());
	CurrentAbilities = DarkInfoState.GetBonusAbilities();
	SoldierAbilities = DarkInfoState.GetSoldierAbilities();

	if(CurrentAbilities.Length >= default.AWCLimit)
	{
		`log("Dark XCom: Soldier has already hit maximum number of AWC abilities.", ,'DarkXCom');
		return;
	}
	
	foreach default.AWCAbilities(CurrentAbility)
	{
		ValidAbilities.AddItem(CurrentAbility.AbilityName);
	}
	ExcludedAbilities = Template.ExcludedAbilities;

	for(i = 0; i < ExcludedAbilities.Length; i++)
	{
		for(k = 0; k < ValidAbilities.Length; k++)
		{
			if(ExcludedAbilities[i] == ValidAbilities[k])
			{
				ValidAbilities.RemoveItem( ValidAbilities[k]);
				break;
			}
		}
	}

	for(i = 0; i < SoldierAbilities.Length; i++)
	{
		for(k = 0; k < ValidAbilities.Length; k++)
		{
			if(SoldierAbilities[i] == ValidAbilities[k])
			{
				ValidAbilities.RemoveItem( ValidAbilities[k]);
				break;
			}
		}
	}

	for(i = 0; i < CurrentAbilities.Length; i++)
	{
		for(k = 0; k < ValidAbilities.Length; k++)
		{
			if(CurrentAbilities[i] == ValidAbilities[k])
			{
				ValidAbilities.RemoveItem( ValidAbilities[k]);
				break;
			}

		}

	}

	AbilityToSend = ValidAbilities[`SYNC_RAND_STATIC(ValidAbilities.Length)];

	`log("Dark XCom: Soldier has earned the AWC ability: " $ AbilityToSend, ,'DarkXCom');

	foreach default.AWCAbilities(CurrentAbility)
	{
		if(CurrentAbility.AbilityName == AbilityToSend)
		{
			DarkInfoState.AddBonusAbility(CurrentAbility);
		}
	}
}

static function XComGameState_Unit_DarkXComInfo GetDarkXComComponent(XComGameState_Unit Unit, optional XComGameState CheckGameState)
{
	local XComGameState_BaseObject TempObj;
	local XComGameStateHistory		History;
	local XComGameState_Unit_DarkXComInfo DarkInfoState;

	if (Unit != none)
	{
		if (CheckGameState != none)
		{
			TempObj = CheckGameState.GetGameStateComponentForObjectID(Unit.GetReference().ObjectID, class'XComGameState_Unit_DarkXComInfo');
			if (TempObj != none)
			{
				DarkInfoState = XComGameState_Unit_DarkXComInfo(TempObj);
			}
		}
		else
		{
			DarkInfoState = XComGameState_Unit_DarkXComInfo(Unit.FindComponentObject(class'XComGameState_Unit_DarkXComInfo'));
		}
		if(DarkInfoState != none){
			return DarkInfoState;
		}
		else //if we're here, this is a unit operating under the new system
		{
			if(CheckGameSTate != none)
			{
				foreach CheckGameState.IterateByClassType(class'XComGameState_Unit_DarkXComInfo', DarkInfoState)
				{
					if(Unit.GetReference().ObjectID == DarkInfoState.ActualOwnerID)
					{

						if(DarkInfoState.ClassName == '') 
						{
							//fix info states with no classes
							DarkInfoState.FixInvalidClass();
						}
						return DarkInfoState;
					}
				}
			}
			// if we're still going, check history
			History = `XCOMHISTORY;
			foreach History.IterateByClassType(class'XComGameState_Unit_DarkXComInfo', DarkInfoState)
			{
				if(Unit.GetReference().ObjectID == DarkInfoState.ActualOwnerID)
				{

					if(DarkInfoState.ClassName == '') 
					{
						//fix info states with no classes
						DarkInfoState.FixInvalidClass();
					}
					return DarkInfoState;
				}
			}
		}

	}
	return none;
}

static function XComGameState_HeadquartersDarkXCom GetDarkXComHQ()
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
	return DarkXComHQ;
}

static function int AssignRecoveryTime(XComGameState_Unit Unit, XComGameState_Unit_DarkXComInfo DarkInfoState, XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local int Output, CurrentHP, MaxHP;

	CurrentHP = Unit.GetCurrentStat(eStat_HP);

	MaxHP = Unit.GetMaxStat(eStat_HP);

	Output = (MaxHP - CurrentHP) * default.NormalHealingRate; //one point of HP lost = 6 days

	if(DarkXComHQ.bAdvancedICUs){
		Output = (MaxHP - CurrentHP) * default.AdvancedHealingRate; //one point of HP lost = 3 days
	}

	return Output;
}


static function bool HasContestingTags(XComGameState_MissionSite MissionState) //we need to do this seperately since we have a strategyrequirement to block the MOCX sitrep from being spawned normally
{
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate, OtherSitrepTemplate;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ; 
	local XComGameState_HeadquartersXCom XComHQ; 
	local MissionDefinition MissionDef;
	local name GameplayTag, SitrepName;
	local int ForceLevel;
	local name Tag;
	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	SitRepTemplate = SitRepManager.FindSitRepTemplate('MOCX');

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ForceLevel = AlienHQ.GetForceLevel();
	MissionDef = MissionState.GeneratedMission.Mission;

	if((SitrepTemplate.MinimumForceLevel > 0 && ForceLevel < SitrepTemplate.MinimumForceLevel) || (SitrepTemplate.MaximumForceLevel > 0 && ForceLevel > SitrepTemplate.MaximumForceLevel))
	{
		return true;
	}

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	foreach SitrepTemplate.TacticalGameplayTags(Tag)
	{
		if(XComHQ.TacticalGameplayTags.Find(Tag) != INDEX_NONE)
		{
			return true;
		}
	}

	foreach SitrepTemplate.ExcludeGameplayTags(Tag)
	{
		if(XComHQ.TacticalGameplayTags.Find(Tag) != INDEX_NONE) //this is for alien rulers
		{
			return true;
		}
	}

	if(MissionDef.sType == "RecoverExpedition")
	{
		return true; //disallow recover expedition missions from MOCX being spawned on it
	}


	if(SitrepTemplate.ValidMissionTypes.Length > 0 && SitrepTemplate.ValidMissionTypes.Find(MissionDef.sType) == INDEX_NONE)
	{
		return true;
	}

	if(SitrepTemplate.ValidMissionFamilies.Length > 0 && SitrepTemplate.ValidMissionFamilies.Find(MissionDef.MissionFamily) == INDEX_NONE)
	{
		return true;
	}

	foreach MissionState.TacticalGameplayTags(GameplayTag)
	{
		if(SitrepTemplate.ExcludeGameplayTags.Find(GameplayTag) != INDEX_NONE)
		{
			return true;
		}
		
	}

	foreach MissionState.GeneratedMission.Sitreps(SitrepName)
	{
		OtherSitrepTemplate = SitRepManager.FindSitRepTemplate(SitrepName);

		if(OtherSitrepTemplate.ExcludeGameplayTags.Find('SITREP_MOCX') != INDEX_NONE)
		{
			return true;
		}

	}
	return false;


}

static function bool IsInvalidMission(X2MissionSourceTemplate MissionTemplate)
{
	if(MissionTemplate.DataName == 'MissionSource_LostAndAbandoned' || MissionTemplate.DataName == 'MissionSource_RescueSoldier' || MissionTemplate.DataName == 'MissionSource_ChosenAmbush') //no limited squad missions
	{
		return true;
	}

	//for my sanity, we shall split checking all invalid mission sources into blocks

	if(MissionTemplate.DataName == 'MissionSource_ChosenStronghold' || MissionTemplate.DataName == 'MissionSource_Broadcast') //|| MissionTemplate.DataName == 'MissionSource_AvengerDefense')
	{
		return true;
	}
	//disabled Strongholds and Sabotage missions because they linger on the geoscape: the SITREP active check will remain active from them.
	  

	if(MissionTemplate.DataName == 'MissionSource_Start' || MissionTemplate.DataName == 'MissionSource_RecoverFlightDevice' || MissionTemplate.DataName == 'MissionSource_AlienNetwork') //no tutorial missions
	{
		return true;
	}

	if(MissionTemplate.DataName == 'MissionSource_AlienNest' || MissionTemplate.DataName == 'MissionSource_LostTowers') // no dlc
	{
		return true;
	}

	return false;

}

static function GivePromotion( XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	DarkInfoState.RankUp(1);
}
static function X2DarkSoldierClassTemplate FindDarkClassTemplate(Name DataName)
{
	local X2DarkSoldierClassTemplate SoldierClassTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local array<X2StrategyElementTemplate> Templates;
	local X2StrategyElementTemplate Template;
	local bool NoClass;

	NoClass = DataName == ''; //if we haev no class name, go with an available class.
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Templates = TemplateManager.GetAllTemplatesOfClass(class'X2DarkSoldierClassTemplate');
	if(!NoClass)
	{
		foreach Templates(Template)
		{
			`log("Dark XCom: Template being checked is " $ Template.DataName, ,'DarkXCom');
			SoldierClassTemplate = X2DarkSoldierClassTemplate(Template);

			if(SoldierClassTemplate != none && DataName == SoldierClassTemplate.DataName)
			{
				return SoldierClassTemplate;
			}
		}
	}
	else
	{

		Template = Templates[`SYNC_RAND_STATIC(Templates.Length)];
		`log("Dark XCom: Template being used due to no class name is " $ Template.DataName, ,'DarkXCom');
		SoldierClassTemplate = X2DarkSoldierClassTemplate(Template);
		if(SoldierClassTemplate != none)
		{
			return SoldierClassTemplate;
		}
	}

}

static function name GetDarkPCS(XComGameState_Unit_DarkXComInfo DarkInfo)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;
	local array<name> PCSesToPick;
	local name PCStoAdd;

	if(!DarkInfo.bIsAlive)
	{
		`log("Dark XCom: this is a dead unit.", ,'DarkXCom');
		return '';
	}
	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
	PCSesToPick = default.NormalPCSes;
	if(DarkXComHQ != none)
	{
		if(DarkXComHQ.bGeneticPCS)
		{
			foreach default.GenePCSes(PCStoAdd)
			{
				PCSesToPick.AddItem(PCStoAdd);
			}
		}

		return PCSesToPick[`SYNC_RAND_STATIC(PCSesToPick.Length)];
	}

	`log("Dark XCom: Could not find DarkXCOMHQ", ,'DarkXCom');
	return PCSesToPick[`SYNC_RAND_STATIC(PCSesToPick.Length)];
}


static function name GetAllDarkPCS(XComGameState_Unit_DarkXComInfo DarkInfo)
{
	local array<name> PCSesToPick;
	local name PCStoAdd;

	if(!DarkInfo.bIsAlive)
	{
		`log("Dark XCom: this is a dead unit.", ,'DarkXCom');
		return '';
	}
	PCSesToPick = default.NormalPCSes;

	foreach default.GenePCSes(PCStoAdd)
	{
		PCSesToPick.AddItem(PCStoAdd);
	}
		

	return PCSesToPick[`SYNC_RAND_STATIC(PCSesToPick.Length)];

}