class X2Character_DarkXCom extends X2Character config(GameData_CharacterStats);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	`log("DARk XCOM: building characters", ,'DarkXCom');
	Templates.AddItem(CreateTemplate_DarkSoldier());
	Templates.AddItem(CreateTemplate_DarkRookie('DarkRookie'));
	Templates.AddItem(CreateTemplate_DarkRookie('DarkRookie_M2'));
	Templates.AddItem(CreateTemplate_DarkRookie('DarkRookie_M3'));

	Templates.AddItem(CreateDarkTemplate('DarkGrenadier'));
	Templates.AddItem(CreateDarkTemplate('DarkRanger'));
	Templates.AddItem(CreateDarkTemplate('DarkSpecialist'));
	Templates.AddItem(CreateDarkTemplate('DarkSniper'));
	Templates.AddItem(CreateDarkTemplate('DarkPsiAgent'));
	Templates.AddItem(CreateDarkTemplate('DarkReclaimed'));

	Templates.AddItem(CreateAdvancedDarkTemplate('DarkSniper'));
	Templates.AddItem(CreateAdvancedDarkTemplate('DarkGrenadier'));
	Templates.AddItem(CreateAdvancedDarkTemplate('DarkRanger'));
	Templates.AddItem(CreateAdvancedDarkTemplate('DarkSpecialist'));
	Templates.AddItem(CreateAdvancedDarkTemplate('DarkPsiAgent'));
	Templates.AddItem(CreateAdvancedDarkTemplate('DarkReclaimed'));

	Templates.AddItem(CreateEliteDarkTemplate('DarkSniper'));
	Templates.AddItem(CreateEliteDarkTemplate('DarkGrenadier'));
	Templates.AddItem(CreateEliteDarkTemplate('DarkRanger'));
	Templates.AddItem(CreateEliteDarkTemplate('DarkSpecialist'));
	Templates.AddItem(CreateEliteDarkTemplate('DarkPsiAgent'));
	Templates.AddItem(CreateEliteDarkTemplate('DarkReclaimed'));

	Templates.AddItem(CreateAdvancedMEC());



	Templates.AddItem(CreateDarkGremlinMag());
	Templates.AddItem(CreateDarkGremlinBeam());


	return Templates;
}

static function X2CharacterTemplate CreateDarkGremlinMag()
{
	local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'DarkGremlinMag');
	CharTemplate.CharacterBaseStats[eStat_HP] = 1;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 0;
	CharTemplate.CharacterBaseStats[eStat_Defense] = 0;
	CharTemplate.CharacterBaseStats[eStat_Mobility] = 12;
	CharTemplate.CharacterBaseStats[eStat_SightRadius] = 0;
	CharTemplate.CharacterBaseStats[eStat_Will] = 50;
	CharTemplate.CharacterBaseStats[eStat_FlightFuel] = 0;
	CharTemplate.CharacterBaseStats[eStat_UtilityItems] = 1;
	CharTemplate.CharacterBaseStats[eStat_AlertLevel] = 2;
	CharTemplate.UnitSize = 1;
	CharTemplate.AvengerOffset.X = 45;
	CharTemplate.AvengerOffset.Y = 90;
	CharTemplate.AvengerOffset.Z = -20;
	CharTemplate.BehaviorClass = class'XGAIBehavior_Civilian';
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = false;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = false;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = false;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanUse_eTraversal_Launch = true;
	CharTemplate.bCanUse_eTraversal_Flying = true;
	CharTemplate.bCanUse_eTraversal_Land = true;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bAppearanceDefinesPawn = false;
	CharTemplate.bIsAfraidOfFire = false;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = false;
	CharTemplate.bIsCosmetic = true;
	CharTemplate.bDisplayUIUnitFlag=false;
	CharTemplate.strPawnArchetypes.AddItem("MOCX_NewAdventWeapons.ARC_GameUnit_GremlinMk2_Advent");
	CharTemplate.bAllowRushCam = false;
	CharTemplate.SoloMoveSpeedModifier = 2.0f;
	CharTemplate.HQIdleAnim = "HL_Idle";
	CharTemplate.HQOffscreenAnim = "HL_FlyUpStart";
	CharTemplate.HQOnscreenAnimPrefix = "HL_FlyDwn";
	CharTemplate.HQOnscreenOffset.X = 0;
	CharTemplate.HQOnscreenOffset.Y = 0;
	CharTemplate.HQOnscreenOffset.Z = 96.0f;

	CharTemplate.Abilities.AddItem('Panicked');
//	CharTemplate.Abilities.AddItem('GremlinForceDeath');

	return CharTemplate;
}

static function X2CharacterTemplate CreateDarkGremlinBeam()
{
	local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'DarkGremlinBeam');
	CharTemplate.CharacterBaseStats[eStat_HP] = 1;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 0;
	CharTemplate.CharacterBaseStats[eStat_Defense] = 0;
	CharTemplate.CharacterBaseStats[eStat_Mobility] = 12;
	CharTemplate.CharacterBaseStats[eStat_SightRadius] = 0;
	CharTemplate.CharacterBaseStats[eStat_Will] = 50;
	CharTemplate.CharacterBaseStats[eStat_FlightFuel] = 0;
	CharTemplate.CharacterBaseStats[eStat_UtilityItems] = 1;
	CharTemplate.CharacterBaseStats[eStat_AlertLevel] = 2;
	CharTemplate.UnitSize = 1;
	CharTemplate.AvengerOffset.X = 45;
	CharTemplate.AvengerOffset.Y = 90;
	CharTemplate.AvengerOffset.Z = -20;
	CharTemplate.BehaviorClass = class'XGAIBehavior_Civilian';
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = false;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = false;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = false;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanUse_eTraversal_Launch = true;
	CharTemplate.bCanUse_eTraversal_Flying = true;
	CharTemplate.bCanUse_eTraversal_Land = true;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bAppearanceDefinesPawn = false;
	CharTemplate.bIsAfraidOfFire = false;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = false;
	CharTemplate.bIsCosmetic = true;
	CharTemplate.bDisplayUIUnitFlag=false;
	CharTemplate.strPawnArchetypes.AddItem("MOCX_NewAdventWeapons.ARC_GameUnit_GremlinMk3_Advent");
	CharTemplate.bAllowRushCam = false;
	CharTemplate.SoloMoveSpeedModifier = 2.0f;

	CharTemplate.HQIdleAnim = "HL_Idle";
	CharTemplate.HQOffscreenAnim = "HL_FlyUpStart";
	CharTemplate.HQOnscreenAnimPrefix = "HL_FlyDwn";
	CharTemplate.HQOnscreenOffset.X = 0;
	CharTemplate.HQOnscreenOffset.Y = 0;
	CharTemplate.HQOnscreenOffset.Z = 96.0f;

	CharTemplate.Abilities.AddItem('Panicked');
//	CharTemplate.Abilities.AddItem('GremlinForceDeath');

	return CharTemplate;
}

static function X2CharacterTemplate CreateAdvancedMEC()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'AdvMEC_MOCX');
	CharTemplate.CharacterGroupName = 'AdventMEC';
	CharTemplate.DefaultLoadout='AdvMEC_M2_Loadout';
	CharTemplate.BehaviorClass=class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "AdvMECMk2_Root"; //basically use the MEC Mk2 root
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_AdvMEC_M2.ARC_GameUnit_AdvMEC_M2");
	Loot.ForceLevel=0;
	Loot.LootTableName='AdvMEC_M2_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvMEC_M2_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvMEC_M2_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);

	CharTemplate.strMatineePackages.AddItem("CIN_AdventMEC");
	CharTemplate.strTargetingMatineePrefix = "CIN_AdventMEC_FF_StartPos";

	CharTemplate.UnitSize = 1;

	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = true;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = false;
	CharTemplate.bCanTakeCover = false;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = false;

	CharTemplate.bAllowSpawnFromATT = true;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bFacesAwayFromPod = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMecs';
	//CharTemplate.strScamperBT = "ScamperRoot_NoCover";
	CharTemplate.strScamperBT = "ScamperRoot_Overwatch";

	CharTemplate.Abilities.AddItem('RobotImmunities');
	CharTemplate.Abilities.AddItem('Formidable');
	CharTemplate.Abilities.AddItem('Bulwark');
	CharTemplate.Abilities.AddItem('AbsorptionField');
	CharTemplate.Abilities.AddItem('RM_Intimidate');
	CharTemplate.Abilities.AddItem('DarkEventAbility_Barrier');
	CharTemplate.Abilities.AddItem('OddNerfTwo');
	CharTemplate.strHackIconImage = "UILibrary_Common.TargetIcons.Hack_robot_icon";
	CharTemplate.strTargetIconImage = "UILibrary_MOCX.TargetIcons.target_mocx";

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_DarkRookie(name templatename)
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate= new(None, string(templatename)) class'X2CharacterTemplate'; CharTemplate.SetTemplateName(templatename);;

	// Auto-Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'MOCX_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvTrooperM1_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvTrooperM1_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);


	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterGroupName = 'DarkXComSoldier';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "DarkSoldierRoot";
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bDiesWhenCaptured = true;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = false;
	CharTemplate.bCanBeRevived = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMOCX';

	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bUsePoolDarkVIPs = true; //these two variables let us use character pool chars

	CharTemplate.bIsTooBigForArmory = false;
	CharTemplate.bStaffingAllowed = false;
	CharTemplate.bAppearInBase = false; // Do not appear as filler crew or in any regular staff slots throughout the base
	CharTemplate.bWearArmorInBase = false;
	
	CharTemplate.bAllowRushCam = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	//CharTemplate.strIntroMatineeSlotPrefix = "Char";
	//CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.strMatineePackages.AddItem("CIN_Advent");
	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	
	//CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = 'RookieDarkSoldier';

	if(templatename == 'DarkRookie_M2')
	{
		CharTemplate.DefaultLoadout = 'RookieDarkSoldier_M2';
	}
	if(templatename == 'DarkRookie_M3')
	{
		CharTemplate.DefaultLoadout = 'RookieDarkSoldier_M3';
	}

	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	//CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	CharTemplate.Abilities.AddItem('DarkEventAbility_HealthBoost');
	//CharTemplate.Abilities.AddItem('FakeBleedout');

	//CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	//CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;

	CharTemplate.strTargetIconImage = "UILibrary_MOCX.TargetIcons.target_mocx";

	//CharTemplate.CustomizationManagerClass = class'XComCharacterCustomization_Hybrid';
	//CharTemplate.UICustomizationMenuClass = class'UICustomize_HybridMenu';
	//CharTemplate.UICustomizationInfoClass = class'UICustomize_HybridInfo';
	//CharTemplate.UICustomizationPropsClass = class'UICustomize_HybridProps';
	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator_DarkXCom';
	
	CharTemplate.PhotoboothPersonality = 'Personality_Normal';

	//CharTemplate.OnEndTacticalPlayFn = SparkEndTacticalPlay;
	//CharTemplate.GetPhotographerPawnNameFn = GetSparkPawnName;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_DarkSoldier()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate= new(None, string('DarkSoldier')) class'X2CharacterTemplate'; CharTemplate.SetTemplateName('DarkSoldier');;

	// Auto-Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'MOCX_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvTrooperM1_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvTrooperM1_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);


	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterGroupName = 'DarkXComSoldier';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "DarkSoldierRoot";
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bDiesWhenCaptured = true;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = false;
	CharTemplate.bCanBeRevived = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMOCX';

	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bUsePoolDarkVIPs = true; //these two variables let us use character pool chars

	CharTemplate.bIsTooBigForArmory = false;
	CharTemplate.bStaffingAllowed = false;
	CharTemplate.bAppearInBase = false; // Do not appear as filler crew or in any regular staff slots throughout the base
	CharTemplate.bWearArmorInBase = false;
	
	CharTemplate.bAllowRushCam = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	//CharTemplate.strIntroMatineeSlotPrefix = "Char";
	//CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.strMatineePackages.AddItem("CIN_Advent");
	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	
	//CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = 'RookieDarkSoldier';
	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	//CharTemplate.Abilities.AddItem('FakeBleedout');

	//CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	//CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;

	CharTemplate.strTargetIconImage = "UILibrary_MOCX.TargetIcons.target_mocx";

	//CharTemplate.CustomizationManagerClass = class'XComCharacterCustomization_Hybrid';
	//CharTemplate.UICustomizationMenuClass = class'UICustomize_HybridMenu';
	//CharTemplate.UICustomizationInfoClass = class'UICustomize_HybridInfo';
	//CharTemplate.UICustomizationPropsClass = class'UICustomize_HybridProps';
	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator_DarkXCom';
	
	CharTemplate.PhotoboothPersonality = 'Personality_Normal';

	//CharTemplate.OnEndTacticalPlayFn = SparkEndTacticalPlay;
	//CharTemplate.GetPhotographerPawnNameFn = GetSparkPawnName;

	return CharTemplate;
}

static function X2CharacterTemplate CreateDarkTemplate(Name DarkName)
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate= new(None, string(DarkName)) class'X2CharacterTemplate'; CharTemplate.SetTemplateName(DarkName);;


	// Auto-Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'MOCX_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvTrooperM1_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvTrooperM1_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);




	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterGroupName = 'DarkXComSoldier';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = (DarkName $ "Root");
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanBeCriticallyWounded = true;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bDiesWhenCaptured = true;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = false;
	CharTemplate.bCanBeRevived = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMOCX';

	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bUsePoolDarkVIPs = true; //these two variables let us use character pool chars

	CharTemplate.bIsTooBigForArmory = false;
	CharTemplate.bStaffingAllowed = false;
	CharTemplate.bAppearInBase = false; // Do not appear as filler crew or in any regular staff slots throughout the base
	CharTemplate.bWearArmorInBase = false;
	
	CharTemplate.bAllowRushCam = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	//CharTemplate.strIntroMatineeSlotPrefix = "Char";
	//CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.strMatineePackages.AddItem("CIN_Advent");
	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	
	//CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = DarkName;
	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('RM_DarkEvac');
	CharTemplate.Abilities.AddItem('RM_DarkAutoEvac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	//CharTemplate.Abilities.AddItem('FakeBleedout');
	CharTemplate.Abilities.AddItem('RM_VanishReveal');
	CharTemplate.Abilities.AddItem('AutoCaptureMOCX');
	CharTemplate.Abilities.AddItem('DarkEventAbility_HealthBoost');
	CharTemplate.Abilities.AddItem('OddNerfOne');
	//CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	//CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;

	CharTemplate.strTargetIconImage = "UILibrary_MOCX.TargetIcons.target_mocx";

	//CharTemplate.CustomizationManagerClass = class'XComCharacterCustomization_Hybrid';
	//CharTemplate.UICustomizationMenuClass = class'UICustomize_HybridMenu';
	//CharTemplate.UICustomizationInfoClass = class'UICustomize_HybridInfo';
	//CharTemplate.UICustomizationPropsClass = class'UICustomize_HybridProps';
	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator_DarkXCom';
	
	CharTemplate.PhotoboothPersonality = 'Personality_Normal';

	//CharTemplate.OnEndTacticalPlayFn = SparkEndTacticalPlay;
	//CharTemplate.GetPhotographerPawnNameFn = GetSparkPawnName;



	return CharTemplate;

}


static function X2CharacterTemplate CreateAdvancedDarkTemplate(Name DarkName)
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate= new(None, (DarkName $ "_M2")) class'X2CharacterTemplate'; CharTemplate.SetTemplateName(name(DarkName $ "_M2"));;


	// Auto-Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'MOCX_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvStunLancerM2_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvStunLancerM2_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);



	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterGroupName = 'DarkXComSoldier';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = (DarkName $ "Root");
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanBeCriticallyWounded = true;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bDiesWhenCaptured = true;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = false;
	CharTemplate.bCanBeRevived = true;

	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bUsePoolDarkVIPs = true; //these two variables let us use character pool chars

	CharTemplate.bIsTooBigForArmory = false;
	CharTemplate.bStaffingAllowed = false;
	CharTemplate.bAppearInBase = false; // Do not appear as filler crew or in any regular staff slots throughout the base
	CharTemplate.bWearArmorInBase = false;
	
	CharTemplate.bAllowRushCam = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	//CharTemplate.strIntroMatineeSlotPrefix = "Char";
	//CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.strMatineePackages.AddItem("CIN_Advent");
	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	
	//CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = name(DarkName $ "_M2");
	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMOCX';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('RM_DarkEvac');
	CharTemplate.Abilities.AddItem('RM_DarkAutoEvac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	//CharTemplate.Abilities.AddItem('FakeBleedout');
	CharTemplate.Abilities.AddItem('RM_VanishReveal');
	CharTemplate.Abilities.AddItem('AutoCaptureMOCX');
	CharTemplate.Abilities.AddItem('DarkEventAbility_HealthBoost');
	CharTemplate.Abilities.AddItem('OddNerfTwo');
	//CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	//CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;

	CharTemplate.strTargetIconImage = "UILibrary_MOCX.TargetIcons.target_mocx";

	//CharTemplate.CustomizationManagerClass = class'XComCharacterCustomization_Hybrid';
	//CharTemplate.UICustomizationMenuClass = class'UICustomize_HybridMenu';
	//CharTemplate.UICustomizationInfoClass = class'UICustomize_HybridInfo';
	//CharTemplate.UICustomizationPropsClass = class'UICustomize_HybridProps';
	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator_DarkXCom';
	
	CharTemplate.PhotoboothPersonality = 'Personality_Normal';

	//CharTemplate.OnEndTacticalPlayFn = SparkEndTacticalPlay;
	//CharTemplate.GetPhotographerPawnNameFn = GetSparkPawnName;



	return CharTemplate;

}


static function X2CharacterTemplate CreateEliteDarkTemplate(Name DarkName)
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate= new(None, (DarkName $ "_M3")) class'X2CharacterTemplate'; CharTemplate.SetTemplateName(name(DarkName $ "_M3"));;


	// Auto-Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'MOCX_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvCaptainM3_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvCaptainM3_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);


	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterGroupName = 'DarkXComSoldier';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = (DarkName $ "Root");
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanBeCriticallyWounded = true;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bDiesWhenCaptured = true;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = false;
	CharTemplate.bCanBeRevived = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMOCX';

	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bUsePoolDarkVIPs = true; //these two variables let us use character pool chars

	CharTemplate.bIsTooBigForArmory = false;
	CharTemplate.bStaffingAllowed = false;
	CharTemplate.bAppearInBase = false; // Do not appear as filler crew or in any regular staff slots throughout the base
	CharTemplate.bWearArmorInBase = false;
	
	CharTemplate.bAllowRushCam = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	//CharTemplate.strIntroMatineeSlotPrefix = "Char";
	//CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.strMatineePackages.AddItem("CIN_Advent");
	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	
	//CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = name(DarkName $ "_M3");
	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('RM_DarkEvac');
	CharTemplate.Abilities.AddItem('RM_DarkAutoEvac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	//CharTemplate.Abilities.AddItem('FakeBleedout');
	CharTemplate.Abilities.AddItem('RM_VanishReveal');
	CharTemplate.Abilities.AddItem('AutoCaptureMOCX');
	CharTemplate.Abilities.AddItem('DarkEventAbility_HealthBoost');
	CharTemplate.Abilities.AddItem('OddNerfThree');
	//CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	//CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;

	CharTemplate.strTargetIconImage = "UILibrary_MOCX.TargetIcons.target_mocx";

	//CharTemplate.CustomizationManagerClass = class'XComCharacterCustomization_Hybrid';
	//CharTemplate.UICustomizationMenuClass = class'UICustomize_HybridMenu';
	//CharTemplate.UICustomizationInfoClass = class'UICustomize_HybridInfo';
	//CharTemplate.UICustomizationPropsClass = class'UICustomize_HybridProps';
	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator_DarkXCom';
	
	CharTemplate.PhotoboothPersonality = 'Personality_Normal';

	//CharTemplate.OnEndTacticalPlayFn = SparkEndTacticalPlay;
	//CharTemplate.GetPhotographerPawnNameFn = GetSparkPawnName;



	return CharTemplate;

}

simulated function string GetAdventMatineePrefix(XComGameState_Unit UnitState)
{
	if(UnitState.kAppearance.iGender == eGender_Male)
	{
		return UnitState.GetMyTemplate().RevealMatineePrefix $ "_Male";
	}
	else
	{
		return UnitState.GetMyTemplate().RevealMatineePrefix $ "_Female";
	}
}