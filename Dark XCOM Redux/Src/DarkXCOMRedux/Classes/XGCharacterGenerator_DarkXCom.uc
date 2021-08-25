class XGCharacterGenerator_DarkXCom extends XGCharacterGenerator config(DarkXCom);

var config bool SoldiersOnly;
var config bool DarkVIPsOnly;
var config bool UseEntireAppearance;

var config bool RandomizePool;

struct ClassCosmetics
{
	var name DarkClassName;					// class this is used for
	var name ArmorName;				// Armor this is meant for
	var int	 iGender;       //use eGender_Male or eGender_Female
	var name Torso;
	var name Legs;
	var name Arms;
	var name LeftArm;
	var name RightArm;
	var name LeftArmDeco;
	var name RightArmDeco;
	var name Thighs; //XPACK added cosmetics
	var name TorsoDeco;
	var name RightForearm;
	var name LeftForearm;
	var name Shins;
	var name Flag;
	var name Voice;
	var name Helmet;
	var name FacePropUpper;
	var name FacePropLower;
};

var config(DarkCustomization) array<ClassCosmetics> SoldierAppearances;
var config(BossData) array<ClassCosmetics> LeaderAppearances;

// for boss 
var config(BossData) bool UseSpecificCharacter;

var config(BossData) string FirstName;
var config(BossData) string LastName;
var config(BossData) string Nickname;

var config(BossData) bool UseFullArmorAppearance;

function XComGameState_Unit GetLeader()
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;
	local array<XComGameState_Unit> CharacterPool, Candidates;
	local string LeaderName;

	LeaderName = (FirstName @ class'UnitDarkXcomUtils'.static.SanitizeQuotes(Nickname) @ LastName);
	Candidates.Length = 0; //remove stale data

	History = `XCOMHISTORY;
	CharacterPool = `CHARACTERPOOLMGR.CharacterPool;

	// skip history check
	if(CharacterPool.length == 0) return none;

	// remove characters who have already appeared this campaign
	foreach CharacterPool(Unit)
	{
		if(Unit.GetName(eNameType_FullNick) == LeaderName)
		{
			break;
		}

	}

	return Unit;
}
 
function XComGameState_Unit GetSoldier(name CharacterTemplateName, out name ClassName)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local XComGameState_Unit Unit;
	local int i;
	local bool SameClass;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	if(CharacterTemplateName == '' || CharacterTemplateName == 'DarkSoldier' || CharacterTemplateName == 'DarkRookie' || CharacterTemplateName == 'DarkRookie_M2' || CharacterTemplateName == 'DarkRookie_M3')
		return none;

	if(DarkXComHQ.Squad.Length < 1)
		return none;

	for(i = 0; i < DarkXComHQ.Squad.Length; i++)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		
		SameClass = MatchNames(CharacterTemplateName, InfoState.GetClassName());

		if(SameClass && !InfoState.bCosmeticDone)
		{
			ClassName = InfoState.GetClassName();
			InfoState.bCosmeticDone = true;
			return Unit;
		}
	}
}

function name GetArmorName(name CharacterTemplateName)
{
	local name ArmorName;
	local int splitIdx;
	ArmorName = 'RM_AdvKevlarArmor';
	splitIdx = InStr(ArmorName, "_M2", true);
	if (splitIdx != INDEX_NONE)
	{
		ArmorName = 'RM_AdvPlatedArmor';
	}
	//we then test for _M3
	splitIdx = InStr(ArmorName, "_M3", true);
	if (splitIdx != INDEX_NONE)
	{
		ArmorName = 'RM_AdvPoweredArmor';
	}
	return ArmorName;
}

function bool MatchNames(name CharacterTemplateName, name InfoName)
{
	local name ActualName;
	local int splitIdx;
	ActualName = CharacterTemplateName;
	if(InfoName == '')
	{
		`log("Dark XCOM: no infostate name for name check.", ,'DarkXCom');
		return false;
	}

	if(ActualName == InfoName) //first we check if the character template name is straight off equivalent
	{
	`log("Dark XCOM: Found right class name.", ,'DarkXCom');
		return true;
	}
	// search for an underscore from the right, in case it's an upgraded tier of soldier
	splitIdx = InStr(ActualName, "_", true);
	if (splitIdx != INDEX_NONE)
	{
		// when we drop the suffix, do our names match now?
		if (name(Left(ActualName, splitIdx)) == InfoName)
		{
			`log("Dark XCOM: Found right class name.", ,'DarkXCom');
			return true;
		}
	}


	`log("Dark XCOM: did not have right class name", ,'DarkXCom');
	return false;

}


static function name GetClassName(name CharacterTemplateName)
{
	local name ActualName;
	local string ClassString;
	local int splitIdx;
	ActualName = CharacterTemplateName;

	if(ActualName == 'DarkGrenadier_M2' || ActualName == 'DarkGrenadier_M3')
	{
	ActualName = 'DarkGrenadier';

	}

	if(ActualName == 'DarkSpecialist_M2' || ActualName == 'DarkSpecialist_M3')
	{
	ActualName = 'DarkSpecialist';

	}

	if(ActualName == 'DarkRanger_M2' || ActualName == 'DarkRanger_M3')
	{
	ActualName = 'DarkRanger';

	}

	if(ActualName == 'DarkSniper_M2' || ActualName == 'DarkSniper_M3')
	{
	ActualName = 'DarkSniper';

	}


	if(ActualName == 'DarkPsiAgent_M2' || ActualName == 'DarkPsiAgent_M3')
	{
	ActualName = 'DarkPsiAgent';

	}

	if(ActualName == 'DarkReclaimed_M2' || ActualName == 'DarkReclaimed_M3')
	{
	ActualName = 'DarkReclaimed';

	}

	// search for an underscore from the right, if none of the above worked
	splitIdx = InStr(ActualName, "_", true);
	if (splitIdx != INDEX_NONE)
	{
		//drop the suffix
		ActualName = name(Left(ActualName, splitIdx));
	}

	return ActualName;
}

function TSoldier CreateTSoldier( optional name CharacterTemplateName, optional EGender eForceGender, optional name nmCountry = '', optional int iRace = -1, optional name ArmorName )
{
	local TSoldier result;
	local array<XComGameState_Unit> Characters;
	local XComGameState_Unit Unit;
	local bool UsingCharPool, HasAppearance, HasClassAppearance; //Class > Standard > General
	local name DarkClassName;
	local ClassCosmetics PossibleAppearance;
	local int i;

	UsingCharPool = true; //this is a check so we use a random soldier when necessary.
	HasAppearance = false; //we set this to false at the start to prevent stale entries;
	HasClassAppearance = false;
	ArmorName = GetArmorName(CharacterTemplateName);
	//so first, we just try to get our appearance from DarkXComHQ if applicable.
	if(CharacterTemplateName != 'MOCX_Leader' && CharacterTemplateName != 'DarkRookie' && CharacterTemplateName != 'DarkRookie_M2' && CharacterTemplateName != 'DarkRookie_M3' && CharacterTemplateName != 'DarkSoldier')
	{

		Unit = GetSoldier(CharacterTemplateName, DarkClassName);
		`log("Character template name is " $ CharacterTemplateName $ " and class name is " $ DarkClassName, ,'DarkXCom');

		if(CharacterTemplateName == 'DarkReclaimed' || CharacterTemplateName == 'DarkReclaimed_M2' || CharacterTemplateName == 'DarkReclaimed_M3')
		{
			result = super.CreateTSoldier('SkirmisherSoldier', EGender(Unit.kAppearance.iGender), Unit.kAppearance.nmFlag, Unit.kAppearance.iRace, ArmorName);
		}
		else
		{
			result = super.CreateTSoldier('Soldier', EGender(Unit.kAppearance.iGender), Unit.kAppearance.nmFlag, Unit.kAppearance.iRace, ArmorName);
		}
	}

	// if not character pool, randomly generate
	if(`CHARACTERPOOLMGR.GetSelectionMode(`XPROFILESETTINGS.Data.m_eCharPoolUsage) != eCPSM_PoolOnly && result.kAppearance.nmHead == '')
	{
		UsingCharPool = false;
		DarkClassName = GetClassName(CharacterTemplateName);
		if(CharacterTemplateName == 'DarkReclaimed' || CharacterTemplateName == 'DarkReclaimed_M2' || CharacterTemplateName == 'DarkReclaimed_M3')
		{
			result = super.CreateTSoldier('SkirmisherSoldier');
		}
		else
		{
			result = super.CreateTSoldier('Soldier');
		}
	}

	Characters = GetCharPoolCandidates(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(CharacterTemplateName));	

	if(RandomizePool && UsingCharPool && result.kAppearance.nmHead == '') //bugfix of sorts: we make MOCX used mixed mode even if the general character pool is set to Pool Only, unless otherwise specified
	{
		i = `SYNC_RAND(100);

		UsingCharPool = i >= 50 ? true : false; //50/50 chance 

	}
	
	if(Characters.length == 0 && result.kAppearance.nmHead == '' || !UsingCharPool && result.kAppearance.nmHead == '')
	{
		DarkClassName = GetClassName(CharacterTemplateName);
		if(CharacterTemplateName == 'DarkReclaimed' || CharacterTemplateName == 'DarkReclaimed_M2' || CharacterTemplateName == 'DarkReclaimed_M3')
		{
			result = super.CreateTSoldier('SkirmisherSoldier');
		}
		else
		{
			result = super.CreateTSoldier('Soldier');
		}
	}

	if(Characters.Length > 0 && UsingCharPool && result.kAppearance.nmHead == '')
	{
		Unit = GetSoldier(CharacterTemplateName, DarkClassName);
		`log("Character template name is " $ CharacterTemplateName $ " and class name is " $ DarkClassName, ,'DarkXCom');
		if(Unit == none)
			Unit = Characters[`SYNC_RAND(Characters.length)];

		if(CharacterTemplateName == 'DarkReclaimed' || CharacterTemplateName == 'DarkReclaimed_M2' || CharacterTemplateName == 'DarkReclaimed_M3')
		{
			result = super.CreateTSoldier('SkirmisherSoldier', EGender(Unit.kAppearance.iGender), Unit.kAppearance.nmFlag, Unit.kAppearance.iRace, ArmorName);
		}
		else
		{
			result = super.CreateTSoldier('Soldier', EGender(Unit.kAppearance.iGender), Unit.kAppearance.nmFlag, Unit.kAppearance.iRace, ArmorName);
		}
		
	}

	//in case we still don't have a class name....
	if(DarkClassName == '')
		DarkClassName = GetClassName(CharacterTemplateName);

	
	if(CharacterTemplateName == 'MOCX_Leader' && UseSpecificCharacter)
	{
		Unit = GetLeader();
		result = super.CreateTSoldier('Soldier', EGender(Unit.kAppearance.iGender), Unit.kAppearance.nmFlag, Unit.kAppearance.iRace, ArmorName);
	}

	// copy name
	if(Unit != none && UsingCharPool || CharacterTemplateName == 'MOCX_Leader')
	{
		result.strFirstName = Unit.GetFirstName();
		result.strLastName = Unit.GetLastName();
		result.strNickName = Unit.GetNickName();
		result.kAppearance.iGender = Unit.kAppearance.iGender;

		if(DarkClassName != 'DarkReclaimed' || CharacterTemplateName != 'DarkReclaimed' || CharacterTemplateName != 'DarkReclaimed_M2' || CharacterTemplateName != 'DarkReclaimed_M3')
		{
			result.kAppearance.nmHead = Unit.kAppearance.nmHead;
			result.kAppearance.nmHaircut = Unit.kAppearance.nmHaircut;
			result.kAppearance.iHairColor = Unit.kAppearance.iHairColor;
			result.kAppearance.nmVoice = Unit.kAppearance.nmVoice;
			result.kAppearance.nmBeard = Unit.kAppearance.nmBeard;

			result.kAppearance.irace = Unit.kAppearance.iRace;
		}

		result.kAppearance.iSkinColor = Unit.kAppearance.iSkinColor;
		result.kAppearance.iEyeColor = Unit.kAppearance.iEyeColor;
		//result.kAppearance.iVoice = Unit.kAppearance.iVoice;
		result.kAppearance.iAttitude = Unit.kAppearance.iAttitude;


		result.kAppearance.iArmorDeco = Unit.kAppearance.iArmorDeco;
	
		result.kAppearance.iArmorTint = Unit.kAppearance.iArmorTint;
		result.kAppearance.iArmorTintSecondary = Unit.kAppearance.iArmorTintSecondary;
	
		result.kAppearance.nmHelmet = Unit.kAppearance.nmHelmet;
		result.kAppearance.nmEye = Unit.kAppearance.nmEye;
		result.kAppearance.nmTeeth = Unit.kAppearance.nmTeeth;
		result.kAppearance.nmFacePropUpper = Unit.kAppearance.nmFacePropUpper;
		result.kAppearance.nmFacePropLower = Unit.kAppearance.nmFacePropLower;
		result.kAppearance.nmPatterns = Unit.kAppearance.nmPatterns;

		result.kAppearance.iTattooTint = Unit.kAppearance.iTattooTint;
		result.kAppearance.nmTattoo_LeftArm = Unit.kAppearance.nmTattoo_LeftArm;
		result.kAppearance.nmTattoo_RightArm = Unit.kAppearance.nmTattoo_RightArm;
		result.kAppearance.nmScars = Unit.kAppearance.nmScars;
		result.kAppearance.nmFacepaint = Unit.kAppearance.nmFacepaint;
	}

	if(!`CHARACTERPOOLMGR.FixAppearanceOfInvalidAttributes(result.kAppearance))
	{
		if(CharacterTemplateName == 'DarkReclaimed' || CharacterTemplateName == 'DarkReclaimed_M2' || CharacterTemplateName == 'DarkReclaimed_M3')
		{
			result = super.CreateTSoldier('SkirmisherSoldier');
		}
		else
		{
			result = super.CreateTSoldier('Soldier');
		}
	}
	result.nmCountry = 'Country_ADVENT';
	result.kAppearance.nmFlag = 'Country_ADVENT';
	if(result.kAppearance.iGender == eGender_Male && CharacterTemplateName != 'MOCX_Leader')
	{
		foreach SoldierAppearances(PossibleAppearance)
		{
			//class and armor specific appearance first
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '' || (PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName != '')) && PossibleAppearance.DarkClassName == DarkClassName && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance) //don't add if we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}
				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasClassAppearance = true;
				`log("Dark XCOM: made class restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
			}
			//then armor specific
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance && !HasAppearance) //don't add if we already have a standard appearance, OR we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasAppearance = true;
				`log("Dark XCOM: made armour restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
			}
			//then general
			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance && !HasAppearance) //don't add if we already have a standard appearance, OR we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				//no appearance bool because we don't want order of elements to affect things: we go through the whole list looking for a more solid match
				`log("Dark XCOM: made general restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
			}

		}
	}
	else if (result.kAppearance.iGender == eGender_Male &&  CharacterTemplateName == 'MOCX_Leader')
	{
		foreach LeaderAppearances(PossibleAppearance)
		{
			//class and armor specific appearance first
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '' || (PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName != '')) && PossibleAppearance.DarkClassName == DarkClassName && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance) //don't add if we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}
				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasClassAppearance = true;
				`log("Dark XCOM: made class restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
			}
			//then armor specific
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance && !HasAppearance) //don't add if we already have a standard appearance, OR we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasAppearance = true;
				`log("Dark XCOM: made armour restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
			}
			//then general
			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance && !HasAppearance) //don't add if we already have a standard appearance, OR we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				//no appearance bool because we don't want order of elements to affect things: we go through the whole list looking for a more solid match
				`log("Dark XCOM: made general restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
			}

		}
	}

	if(result.kAppearance.iGender == eGender_Female && CharacterTemplateName != 'MOCX_Leader')
	{
		foreach SoldierAppearances(PossibleAppearance)
		{
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '' || (PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName != '')) && PossibleAppearance.DarkClassName == DarkClassName && PossibleAppearance.iGender == eGender_Female && !HasClassAppearance) //don't add if we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasClassAppearance = true;
				`log("Dark XCOM: made class restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
				//break;
			}

			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female && !HasClassAppearance && !HasAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasAppearance = true;
				`log("Dark XCOM: made armour restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
				//break;
			}

			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female  && !HasClassAppearance && !HasAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				//no appearance bool because we don't want order of elements to affect things: we go through the whole list looking for a more solid match
				`log("Dark XCOM: made general restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
				//break;
			}

		}
	}
	else if(result.kAppearance.iGender == eGender_Female && CharacterTemplateName == 'MOCX_Leader')
	{
		foreach LeaderAppearances(PossibleAppearance)
		{
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '' || (PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName != '')) && PossibleAppearance.DarkClassName == DarkClassName && PossibleAppearance.iGender == eGender_Female && !HasClassAppearance) //don't add if we already have a class appearance
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasClassAppearance = true;
				`log("Dark XCOM: made class restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
				//break;
			}

			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female && !HasClassAppearance && !HasAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasAppearance = true;
				`log("Dark XCOM: made armour restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
				//break;
			}

			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female  && !HasClassAppearance && !HasAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				//no appearance bool because we don't want order of elements to affect things: we go through the whole list looking for a more solid match
				`log("Dark XCOM: made general restricted appearance for " $ CharacterTemplateName, ,'DarkXCom');
				//break;
			}

		}
	}
	//result.kAppearance.nmCountry ='';

	//// non-VIPs can have their appearance copied wholesale
	if(UseEntireAppearance && Unit != none && UsingCharPool && CharacterTemplateName != 'MOCX_Leader')
	{
		result.kAppearance = Unit.kAppearance;
	}
	else if(CharacterTemplateName == 'MOCX_Leader' && UseFullArmorAppearance && Unit != none )
	{
		result.kAppearance = Unit.kAppearance;
	}

	// fix XComGameState_Unit attributes (background, whatever else VIPs have) via UI listener
	// shouldn't be any major incompatibility with Configurable Birthdates

	return result;
}

function array<XComGameState_Unit> GetCharPoolCandidates(X2CharacterTemplate Template)
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
		if(Filter(CharacterPool[i], Template))
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
		
		if(Unit.GetMyTemplateName() == 'SkirmisherSoldier' && Unit.GetMyTemplateName() != 'DarkSoldier') 
		{
			if(Candidates[i].GetName(eNameType_FullNick) == class'UnitDarkXComUtils'.static.GetFullName(Unit))
			{
				Candidates.Remove(i, 1); // auto remove skrimishers
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

static function bool Filter(XComGameState_Unit Unit, X2CharacterTemplate CharacterTemplate)
{
	// bugfix for CharacterPoolManager, allow human characters to be anything
	if((Unit.GetMyTemplateName() != 'Soldier' || Unit.GetMyTemplateName() != 'SkirmisherSoldier') && Unit.GetMyTemplateName() != CharacterTemplate.DataName)
		return false;

	if (CharacterTemplate.bUsePoolSoldiers && Unit.bAllowedTypeSoldier && CharacterTemplate.bUsePoolDarkVIPs && Unit.bAllowedTypeDarkVIP)
		return true;

	if (CharacterTemplate.bUsePoolSoldiers && Unit.bAllowedTypeSoldier && default.SoldiersOnly)
		return true;

	if (CharacterTemplate.bUsePoolDarkVIPs && Unit.bAllowedTypeDarkVIP && default.DarkVIPsOnly)
		return true;

	return false;
}


static function UseProxyAppearance(XComGameState_Unit result, name LoadoutName, name ArmorName)
{
	local ClassCosmetics PossibleAppearance;
	local XComGameState_Item Item;
	local X2ItemTemplate ArmorTemplate;
	local bool HasAppearance, HasClassAppearance;

	Item = result.GetItemInSlot( eInvSlot_Armor );
	ArmorTemplate = Item.GetMyTemplate();

	if(ArmorName == '' && ArmorTemplate != none)
		ArmorName = ArmorTemplate.DataName;

	HasAppearance = false;
	HasClassAppearance = false;

	//in case we still don't have a class name....
	if(LoadoutName == '')
		LoadoutName = GetClassName(result.GetMyTemplateName());


	if(result.kAppearance.iGender == eGender_Male)
	{
		foreach default.SoldierAppearances(PossibleAppearance)
		{
			//class and armor (or just class) specific appearance first
			if((PossibleAppearance.ArmorName == ArmorName || (ArmorName == '' && PossibleAppearance.DarkClassName != '') || (PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName != '')) && PossibleAppearance.DarkClassName == LoadoutName && PossibleAppearance.iGender == eGender_Male && !HasClassAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasClassAppearance = true;
				`log("Dark XCOM: made class restricted appearance for " $ LoadoutName, ,'DarkXCom');
				//break;
			}
			//then armor specific
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male && !HasAppearance && !HasClassAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasAppearance = true;
				`log("Dark XCOM: made armour restricted appearance for " $ LoadoutName, ,'DarkXCom');
				//break;
			}
			//then general
			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male && !HasAppearance && !HasClassAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				//no bool for general: load order may mean general was first and more specific options were later
				`log("Dark XCOM: made general restricted appearance for " $ LoadoutName, ,'DarkXCom');
				//break;
			}

		}
	}

	if(result.kAppearance.iGender == eGender_Female)
	{
		foreach default.SoldierAppearances(PossibleAppearance)
		{
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '' || (PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName != '')) && PossibleAppearance.DarkClassName == LoadoutName && PossibleAppearance.iGender == eGender_Female && !HasClassAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasClassAppearance = true;
				`log("Dark XCOM: made class restricted appearance for " $ LoadoutName, ,'DarkXCom');
				//break;
			}

			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female && !HasAppearance && !HasClassAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				HasAppearance = true;
				`log("Dark XCOM: made armour restricted appearance for " $ LoadoutName, ,'DarkXCom');
				//break;
			}

			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female && !HasAppearance && !HasClassAppearance)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				if(PossibleAppearance.Helmet != '')
				{
					result.kAppearance.nmHelmet = PossibleAppearance.Helmet;
				}
				if(PossibleAppearance.FacePropUpper != '')
				{
					result.kAppearance.nmFacePropUpper = PossibleAppearance.FacePropUpper;
				}
				if(PossibleAppearance.FacePropLower != '')
				{
					result.kAppearance.nmFacePropLower = PossibleAppearance.FacePropLower;
				}
				//no bool: we must go through all possible options before we settle with general
				`log("Dark XCOM: made general restricted appearance for " $ LoadoutName, ,'DarkXCom');
				//break;
			}

		}
	}



}