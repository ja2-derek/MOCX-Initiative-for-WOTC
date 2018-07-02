class X2AbilitySet_DarkXCom extends X2Ability dependson (XComGameStateContext_Ability) config(GameData_WeaponData);

var config int SMG_CONVENTIONAL_MOBILITY_BONUS;
var config float SMG_CONVENTIONAL_DETECTIONRADIUSMODIFER;

var config int PSIAMP_CV_STATBONUS;
var config int PSIAMP_MG_STATBONUS;
var config int PSIAMP_BM_STATBONUS;

var config int KEVLAR_HP;
var config int PLATED_HP;
var config int POWERED_HP;
var config int KEVLAR_AP;
var config int PLATED_AP;
var config int POWERED_AP;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	`log("Dark XCOM: building abilities", ,'DarkXCom');
	Templates.AddItem(AddLauncherAbility());
	Templates.AddItem(CreateLongJump());
	Templates.AddItem(CreateMimeticSkin());
	Templates.AddItem(CreateIntimidate());
	Templates.AddItem(CreateIntimidateTrigger());
	Templates.AddItem(CreateFakeBleedout());
	Templates.AddItem(CreateFakeBleedoutTrigger());
	//Templates.AddItem(CreateDarkKillCounter());


	Templates.AddItem(AddSMGConventionalBonusAbility());

	Templates.AddItem(CreateAdvKevlarArmorStats());
	Templates.AddItem(CreateAdvPlatedArmorStats());
	Templates.AddItem(CreateAdvPoweredArmorStats());

	Templates.AddItem(CreateDarkEvac());
	Templates.AddItem(CreateDarkEvacTeleport());
	Templates.AddItem(CreateVanish());
	Templates.AddItem(CreateStartVanish());
	Templates.AddItem(CreateVanishReveal());

	Templates.AddItem(AddPsiAmpMG_BonusStats());
	Templates.AddItem(AddPsiAmpCG_BonusStats());
	Templates.AddItem(AddPsiAmpBM_BonusStats());
	Templates.AddItem(PurePassive('FearOfMOCXPassive', "img:///UILibrary_XPACK_Common.PerkIcons.weakx_fearofchosen", , 'eAbilitySource_Debuff'));

//	Templates.AddItem(GremlinForceDeath());

	Templates.AddItem(ExecuteMOCX());
	Templates.AddItem(AutoCaptureMOCX());
	Templates.AddItem(DarkEventAbility_HealthBoost());
	Templates.AddItem(CreateAutoDarkEvac());

	Templates.AddItem(OddNerfOne());
	Templates.AddItem(OddNerfTwo());
	Templates.AddItem(OddNerfThree());

	return Templates;
}
static function X2DataTemplate OddNerfThree()
{
	local X2AbilityTemplate Template;
	local X2Effect_OddNerf ShieldEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'OddNerfThree');

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.str_immunetoexplosives";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDontDisplayInAbilitySummary = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ShieldEffect = new class'X2Effect_OddNerf';
	ShieldEffect.BuildPersistentEffect(1, true, true, true);
	ShieldEffect.ExplosiveDamageReduction = 0.5f;
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, , , Template.AbilitySourceName);
	Template.AddTargetEffect(ShieldEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;


	return Template;
}

static function X2DataTemplate OddNerfTwo()
{
	local X2AbilityTemplate Template;
	local X2Effect_OddNerf ShieldEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'OddNerfTwo');

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.str_immunetoexplosives";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDontDisplayInAbilitySummary = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ShieldEffect = new class'X2Effect_OddNerf';
	ShieldEffect.BuildPersistentEffect(1, true, true, true);
	ShieldEffect.ExplosiveDamageReduction = 0.4f;
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, , , Template.AbilitySourceName);
	Template.AddTargetEffect(ShieldEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;


	return Template;
}
static function X2DataTemplate OddNerfOne()
{
	local X2AbilityTemplate Template;
	local X2Effect_OddNerf ShieldEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'OddNerfOne');

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.str_immunetoexplosives";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDontDisplayInAbilitySummary = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ShieldEffect = new class'X2Effect_OddNerf';
	ShieldEffect.BuildPersistentEffect(1, true, true, true);
	ShieldEffect.ExplosiveDamageReduction = 0.2f;
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, , , Template.AbilitySourceName);
	Template.AddTargetEffect(ShieldEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;


	return Template;
}


static function X2DataTemplate CreateAutoDarkEvac()
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent EscapeEffect;
	local X2AbilityTrigger_PlayerInput Trigger;
	local X2AbilityCooldown          Cooldown;
	local X2Condition_DarkEvac			DarkEvac;
	local X2AbilityTrigger_EventListener EventListener;
	local X2Condition_UnitStatCheck         UnitStatCheckCondition; //explicit check for HP
	Template= new(None, string('RM_DarkAutoEvac')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_DarkAutoEvac');;;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_evac";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;


	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
	Template.AbilityShooterConditions.AddItem(UnitStatCheckCondition);


	DarkEvac = new class'X2Condition_DarkEvac';
	Template.AbilityTargetConditions.AddItem(DarkEvac);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;


	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitBleedingOut'; //auto-calls for evac if bleeding out
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Priority = 45; //should fire before the game does anything else to the unit
	Template.AbilityTriggers.AddItem(EventListener);

	EscapeEffect = new class'X2Effect_Persistent';
	EscapeEffect.BuildPersistentEffect(3, false, false, false, eGameRule_PlayerTurnEnd);
	EscapeEffect.EffectName = 'RM_Escaping';
	EscapeEffect.EffectRemovedFn = DarkEvacEscapeFn;
	Template.AddShooterEffect(EscapeEffect);	


	//Template.ActivationSpeech = 'EVACrequest';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	//Template.CustomFireAnim = 'HL_SignalPoint';
	Template.CinescriptCameraType = "Mark_Target";


	return Template;
}

static function X2AbilityTemplate DarkEventAbility_HealthBoost()
{
	local X2AbilityTemplate						Template;
	local X2Condition_GameplayTag				GameplayCondition;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_PersistentStatChange			DefenseChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkEventAbility_HealthBoost');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	DefenseChangeEffect = new class'X2Effect_PersistentStatChange';
	DefenseChangeEffect.BuildPersistentEffect(1, true, false, true);
	DefenseChangeEffect.AddPersistentStatChange(eStat_HP, 3);
	DefenseChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), "UILibrary_XPACK_Common.PerkIcons.UIPerk_barrierdarkevent");
	DefenseChangeEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect( DefenseChangeEffect );

	GameplayCondition = new class'X2Condition_GameplayTag';
	GameplayCondition.RequiredGameplayTag = 'DarkEvent_HealthBoosters';
	Template.AbilityShooterConditions.AddItem(GameplayCondition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}


static function X2AbilityTemplate AutoCaptureMOCX()
{
	local X2AbilityTemplate             Template;
	local X2Effect_AutoCapture	CaptureEffect;
	Template = PurePassive('AutoCaptureMOCX', "img:///UILibrary_PerkIcons.UIPerk_combatstims",,, false);
	

	//`CREATE_X2ABILITY_TEMPLATE(Template, 'ExperimentalStims');

	//Template.AbilityCosts.AddItem(default.FreeActionCost);
//	Template.AbilityCosts.AddItem(new class'X2AbilityCost_ConsumeItem');
//
	//Template.AbilityToHitCalc = default.DeadEye;
	//Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	//Template.AbilityTargetStyle = default.SelfTarget;
	//Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
//
	Template.Hostility = eHostility_Defensive;
	//Template.AbilitySourceName = 'eAbilitySource_Item';
	//Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatstims";
	//Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	//Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.COMBAT_STIMS_PRIORITY;
	//Template.ActivationSpeech = 'CombatStim';
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	//Template.CustomSelfFireAnim = 'FF_FireMedkitSelf';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	CaptureEffect = new class'X2Effect_AutoCapture';
	CaptureEffect.BuildPersistentEffect(1, true, true, true);
	Template.AddTargetEffect(CaptureEffect);

	return Template;
}
static function X2AbilityTemplate ExecuteMOCX()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;
	local X2Condition_UnitProperty          TargetCondition, ShooterCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ExecuteMOCX');
	
	// Costs one action point, just like normal stabilize.
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	// Standard restrictions apply to the operator; must be alive, must not be panicked, etc.
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);
	Template.AddShooterEffectExclusions();
	
	// The target conditions: Must be a friendly, must be within carry range, must be bleeding out.
	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;               
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeFriendlyToSource = true;
	TargetCondition.ExcludeHostileToSource = false;     
	TargetCondition.RequireWithinRange = true;
	TargetCondition.IsBleedingOut = true;
	TargetCondition.WithinRange = class'X2Ability_CarryUnit'.default.CARRY_UNIT_RANGE; 
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	//execute bleeding out targets
	Template.AddTargetEffect(new class'X2Effect_Executed');

	
	SingleTarget = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = SingleTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_coupdegrace";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STABILIZE_PRIORITY;
	Template.Hostility = eHostility_Offensive;
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.CustomFireAnim = 'FF_Melee';
	//Template.ActivationSpeech = 'StabilizingAlly';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bDontDisplayInAbilitySummary = true;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}


static function EventListenerReturn IsOwnerDead(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, OwnerState, CosmeticUnit;
	local XComGameState NewGameState;
	local XComGameState_Item ItemState;
	local XComGameStateContext_ChangeContainer ChangeContext;

	UnitState = XComGameState_Unit(EventSource);
	foreach GameState.IterateByClassType(class'XComGameState_Item', ItemState)
	{

		if(ItemState.OwnerStateObject.ObjectID > 0)
		{
			History = `XCOMHISTORY;
			OwnerState = XComGameState_Unit(History.GetGameStateForObjectID(ItemState.OwnerStateObject.ObjectID));

			if(UnitState.ObjectID == OwnerState.ObjectID) //owner dead, pls kill us
			{
				CosmeticUnit = XComGameState_Unit(History.GetGameStateForObjectID(ItemState.CosmeticUnitRef.ObjectID));

				if(!CosmeticUnit.IsAlive());
					return ELR_NoInterrupt; //no need to kill ourselves if we're already dead
					
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Owner Unit Died");
				ChangeContext = XComGameStateContext_ChangeContainer(NewGameState.GetContext());
				ChangeContext.BuildVisualizationFn = ItemState.ItemOwnerDeathVisualization;
				CosmeticUnit = XComGameState_Unit(NewGameState.ModifyStateObject(CosmeticUnit.Class, CosmeticUnit.ObjectID));
				CosmeticUnit.SetCurrentStat(eStat_HP, 0);
				`GAMERULES.SubmitGameState(NewGameState);
				break; //
			}
		}

			
	}

	return ELR_NoInterrupt;
}

static function X2AbilityTemplate GremlinForceDeath()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTarget_Self					TargetStyle;
	local X2AbilityTrigger_EventListener		EventListener;
	//local X2Condition_OwnerIsDead				GameplayCondition;
	local X2Effect_KillUnit						KillUnitEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GremlinForceDeath');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventFn = IsOwnerDead;
	EventListener.ListenerData.EventID = 'UnitDied';
	EventListener.ListenerData.Priority = 45;  //This ability must get triggered after the rest of the on-death listeners (namely, after mind-control effects get removed)
	Template.AbilityTriggers.AddItem(EventListener);
//
	//GameplayCondition = new class'X2Condition_OwnerIsDead';
	//Template.AbilityShooterConditions.AddItem(GameplayCondition);
//
	// If the unit is alive, kill it
	KillUnitEffect = new class'X2Effect_KillUnit';
	KillUnitEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	KillUnitEffect.EffectName = 'KillUnit';
	Template.AddTargetEffect(KillUnitEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
//	Template.MergeVisualizationFn = SwitchPsiZombie_VisualizationMerge;
//
	return Template;
}

// ******************* Psi Amp Bonus ********************************
static function X2AbilityTemplate AddPsiAmpMG_BonusStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkPsiAmpMG_BonusStats');
	Template.IconImage = "img:///gfxXComIcons.psi_telekineticfield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Bonus to hacking stat Effect
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_PsiOffense, default.PSIAMP_CV_STATBONUS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AddPsiAmpCG_BonusStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkPsiAmpCG_BonusStats');
	Template.IconImage = "img:///gfxXComIcons.psi_telekineticfield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Bonus to hacking stat Effect
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_PsiOffense, default.PSIAMP_MG_STATBONUS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}
static function X2AbilityTemplate AddPsiAmpBM_BonusStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkPsiAmpBM_BonusStats');
	Template.IconImage = "img:///gfxXComIcons.psi_telekineticfield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Bonus to hacking stat Effect
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_PsiOffense, default.PSIAMP_BM_STATBONUS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2DataTemplate CreateVanishReveal()
{
	local X2AbilityTemplate Template;
	local X2Condition_UnitEffects UnitEffectsCondition;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Condition_UnitStatCheck AlertCheck;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_VanishReveal');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanishingwind";
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	//Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// This ability fires can when the unit gets hit by a scan
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = class'X2Effect_ScanningProtocol'.default.ScanningProtocolTriggeredEventName;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires when the unit is flanked by an enemy
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_UnitIsFlankedByMovedUnit;
	Trigger.ListenerData.EventID = 'UnitMoveFinished';
	Template.AbilityTriggers.AddItem(Trigger);

	//	This functionality has been deprecated -jbouscher
	// This ability fires when a linked Shadowbound unit dies
	//Trigger = new class'X2AbilityTrigger_EventListener';
	//Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	//Trigger.ListenerData.EventID = 'UnitDied';
	//Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.ShadowboundDeathRevealListener;
	//Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires when the unit is damaged
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires when the unit takes a hostile action
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'AbilityActivated';
	Trigger.ListenerData.EventFn = WasHostileAction;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);


	// This ability fires when the unit gets a certain effect added to it
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_VanishedUnitPersistentEffectAdded;
	Trigger.ListenerData.EventID = 'PersistentEffectAdded';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// The shooter must have the Vanish Effect
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddRequireEffect('RM_Vanish', 'AA_MissingRequiredEffect');
	Template.AbilityShooterConditions.AddItem(UnitEffectsCondition);

	//rangers can't be revealed until they're alerted to XCOM.
	AlertCheck = new class'X2Condition_UnitStatCheck';
	AlertCheck.AddCheckStat(eStat_AlertLevel, 1, eCheck_GreaterThan); //red alert = 2
	Template.AbilityShooterConditions.AddItem(AlertCheck);

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem('RM_Vanish');
	Template.AddShooterEffect(RemoveEffects);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.MergeVisualizationFn = class'X2Ability_ChosenAssassin'.static.VanishingWindReveal_MergeVisualization;

	Template.bSkipFireAction = true;
	Template.bShowPostActivation = true;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.CinescriptCameraType = "VanishRevealAbility";
	
	return Template;
}


static function EventListenerReturn WasHostileAction(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory History;
	//local XComGameStateContext_Ability AbilityContext;
	//local XComGameState NewGameState;
	local XComGameState_Ability AbilityState, VanishState;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Unit SourceUnit;
	local StateObjectReference VanishRef;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(EventSource);
	AbilityState = XComGameState_Ability(EventData);
	AbilityTemplate = AbilityState.GetMyTemplate();
	//AbilityContext = XComGameStateContext_Ability(GameState.GetContext().GetFirstStateInEventChain().GetContext());
	if(AbilityTemplate == none || AbilityTemplate.Hostility != eHostility_Offensive)
	{
		//wasn't offensive, ignore
		return ELR_NoInterrupt;
	}

	VanishRef = SourceUnit.FindAbility('RM_VanishReveal');
	if (VanishRef.ObjectID == 0)
		return ELR_NoInterrupt;

	VanishState = XComGameState_Ability(History.GetGameStateForObjectID(VanishRef.ObjectID));
	if (VanishState == None)
		return ELR_NoInterrupt;
	
	
	VanishState.AbilityTriggerAgainstSingleTarget(SourceUnit.GetReference(), false);		
	return ELR_NoInterrupt;
}

static function X2DataTemplate CreateStartVanish()
{
	local X2AbilityTemplate Template;
	//local X2AbilityCost_ActionPoints ActionPointCost;
	//local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Effect_Vanish VanishEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_VanishPhantom');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanishingwind";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AdditionalAbilities.AddItem('RM_VanishReveal');

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(class'X2Effect_Vanish'.static.VanishShooterEffectsCondition());

	// Add remove suppression
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_Suppression'.default.EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_TargetDefinition'.default.EffectName);
	Template.AddTargetEffect(RemoveEffects);

	VanishEffect = new class'X2Effect_Vanish';
	VanishEffect.BuildPersistentEffect(1, true, false, true);
	//VanishEffect.AddPersistentStatChange(eStat_Mobility, default.VANISH_MOBILITY_INCREASE, MODOP_Multiplication);
	//VanishEffect.VanishRevealAnimName = 'HL_Vanish_Stop';
	//VanishEffect.VanishSyncAnimName = 'ADD_Vanish_Restart';
	VanishEffect.EffectName = 'RM_Vanish';
	Template.AddTargetEffect(VanishEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowActivation = false;

	Template.CinescriptCameraType = "VanishAbility";
//BEGIN AUTOGENERATED CODE: Template Overrides 'Vanish'
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSKipFireAction = true;
	//Template.CustomFireAnim = 'HL_Vanish_Start';
//END AUTOGENERATED CODE: Template Overrides 'Vanish'
	
	return Template;
}

static function X2DataTemplate CreateVanish()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Effect_Vanish VanishEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_Vanish');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanishingwind";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	Template.AdditionalAbilities.AddItem('RM_VanishReveal');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = class'X2Ability_Spectre'.default.VANISH_COOLDOWN_LOCAL;
	Cooldown.NumGlobalTurns = class'X2Ability_Spectre'.default.VANISH_COOLDOWN_GLOBAL;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(class'X2Effect_Vanish'.static.VanishShooterEffectsCondition());

	// Add remove suppression
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_Suppression'.default.EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_TargetDefinition'.default.EffectName);
	Template.AddTargetEffect(RemoveEffects);

	VanishEffect = new class'X2Effect_Vanish';
	VanishEffect.BuildPersistentEffect(1, true, false, true);
	//VanishEffect.AddPersistentStatChange(eStat_Mobility, default.VANISH_MOBILITY_INCREASE, MODOP_Multiplication);
	//VanishEffect.VanishRevealAnimName = 'HL_Vanish_Stop';
	//VanishEffect.VanishSyncAnimName = 'ADD_Vanish_Restart';
	VanishEffect.EffectName = 'RM_Vanish';
	Template.AddTargetEffect(VanishEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowActivation = true;

	Template.CinescriptCameraType = "VanishAbility";
//BEGIN AUTOGENERATED CODE: Template Overrides 'Vanish'
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;
	//Template.CustomFireAnim = 'HL_Vanish_Start';
//END AUTOGENERATED CODE: Template Overrides 'Vanish'
	
	return Template;
}

static function X2DataTemplate CreateDarkEvac()
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent EscapeEffect;
	local X2AbilityTrigger_PlayerInput Trigger;
	local X2AbilityCooldown          Cooldown;
	local X2Condition_DarkEvac			DarkEvac;
	local X2AbilityTrigger_EventListener EventListener;
	local X2Condition_UnitStatCheck         UnitStatCheckCondition; //explicit check for HP
	Template= new(None, string('RM_DarkEvac')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_DarkEvac');;;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_evac";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;


	Template.AbilityCosts.AddItem(default.FreeActionCost);


	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
	Template.AbilityShooterConditions.AddItem(UnitStatCheckCondition);


	DarkEvac = new class'X2Condition_DarkEvac';
	Template.AbilityTargetConditions.AddItem(DarkEvac);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(Trigger);


	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitBleedingOut'; //auto-calls for evac if bleeding out
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Priority = 45; //should fire before the game does anything else to the unit
	Template.AbilityTriggers.AddItem(EventListener);

	EscapeEffect = new class'X2Effect_Persistent';
	EscapeEffect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
	EscapeEffect.EffectName = 'RM_Escaping';
	EscapeEffect.EffectRemovedFn = DarkEvacEscapeFn;
	Template.AddShooterEffect(EscapeEffect);	

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	Template.ActivationSpeech = 'EVACrequest';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	//Template.CustomFireAnim = 'HL_SignalPoint';
	Template.CinescriptCameraType = "Mark_Target";
	
	Template.AdditionalAbilities.AddItem('RM_EvacTeleport');

	return Template;
}


static function X2DataTemplate CreateDarkEvacTeleport()
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent EscapeEffect;
	local X2AbilityTrigger_EventListener EventListener;
	local X2Condition_UnitStatCheck         UnitStatCheckCondition; //explicit check for HP

	Template= new(None, string('RM_EvacTeleport')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_EvacTeleport');;;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_evac";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	//Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
	Template.AbilityShooterConditions.AddItem(UnitStatCheckCondition);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'RM_TeleportOut';
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self_VisualizeInGameState;
	EventListener.ListenerData.Priority = 45; //This ability must get triggered after the rest of the on-death listeners (namely, after mind-control effects get removed)
	Template.AbilityTriggers.AddItem(EventListener);

	EscapeEffect = new class'X2Effect_Persistent';
	EscapeEffect.EffectName = 'RM_Escaped';
	EscapeEffect.EffectAddedFn = DarkEscapeFn;
	Template.AddShooterEffect(EscapeEffect);	

	//Template.ActivationSpeech = 'EVACrequest';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = DarkEvac_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	//Template.CustomFireAnim = 'HL_SignalPoint';
	//Template.CinescriptCameraType = "Mark_Target";


	return Template;
}

simulated function DarkEvac_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateContext_Ability Context;
	local XComGameStateHistory History;
	local VisualizationActionMetadata EmptyTrack, DeadUnitTrack;
	local XComGameState_Unit DeadUnit;
	local XComContentManager ContentManager;
	local TTile SpawnedUnitTile;
	local X2Action_PlayEffect PsiWarpInEffectAction;
	local XComWorldData World;
	local X2Action_PlaySoundAndFlyOver  SoundAndFlyover;

	World = `XWORLD;
	ContentManager = `CONTENT;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	History = `XCOMHISTORY;

	DeadUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	`assert(DeadUnit != none);

	// The Spawned unit should appear and play its change animation
	DeadUnitTrack = EmptyTrack;
	DeadUnitTrack.StateObject_OldState = DeadUnit;
	DeadUnitTrack.StateObject_NewState = DeadUnitTrack.StateObject_OldState;
	DeadUnitTrack.VisualizeActor = History.GetVisualizer(DeadUnit.ObjectID);

	DeadUnit.GetKeystoneVisibilityLocation(SpawnedUnitTile);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyover(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(DeadUnitTrack, VisualizeGameState.GetContext()));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", 'EVAC', eColor_Good);

	PsiWarpInEffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(DeadUnitTrack, VisualizeGameState.GetContext()));
	PsiWarpInEffectAction.EffectName = ContentManager.PsiWarpInEffectPathName;
	PsiWarpInEffectAction.EffectLocation = World.GetPositionFromTileCoordinates(SpawnedUnitTile);
	PsiWarpInEffectAction.bStopEffect = false;
	
	//Hide the pawn explicitly now - in case the vis block doesn't complete immediately to trigger an update
	class'X2Action_RemoveUnit'.static.AddToVisualizationTree(DeadUnitTrack, VisualizeGameState.GetContext());


}

static function DarkEscapeFn( X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit RulerState;
	//local X2EventManager EventManager;

	//EventManager = class'X2EventManager'.static.GetEventManager();

	RulerState = XComGameState_Unit(kNewTargetState);
	RulerState.EvacuateUnit(NewGameState);
//	EventManager.TriggerEvent('UnitRemovedFromPlay', RulerState, RulerState, NewGameState);
//	EventManager.TriggerEvent('UnitEvacuated', RulerState, RulerState, NewGameState);

}


static function DarkEvacEscapeFn(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed)
{
	local XComGameState_Unit RulerState;
	local X2EventManager EventManager;

	EventManager = class'X2EventManager'.static.GetEventManager();

	RulerState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EventManager.TriggerEvent('RM_TeleportOut', RulerState, RulerState, NewGameState);

}



static function X2AbilityTemplate CreateAdvKevlarArmorStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_AdvKevlarArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// giving health here; medium plated doesn't have mitigation
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.KEVLAR_HP);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.KEVLAR_AP);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}


static function X2AbilityTemplate CreateAdvPlatedArmorStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_AdvPlatedArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// giving health here; medium plated doesn't have mitigation
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.PLATED_HP);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.PLATED_AP);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}


static function X2AbilityTemplate CreateAdvPoweredArmorStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_AdvPoweredArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// giving health here; medium plated doesn't have mitigation
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.POWERED_HP);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.POWERED_AP);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AddSMGConventionalBonusAbility()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SMG_Dark_StatBonus');
	Template.IconImage = "img:///gfxXComIcons.NanofiberVest";  

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to Mobility and DetectionRange stat effects
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, "", "", Template.IconImage, false,,Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.SMG_CONVENTIONAL_MOBILITY_BONUS);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_DetectionModifier, default.SMG_CONVENTIONAL_DETECTIONRADIUSMODIFER);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}


static function X2AbilityTemplate CreateFakeBleedout()
{
	local X2AbilityTemplate             Template;
	local X2Effect_FakeBleedout              SustainEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FakeBleedOut');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sustain";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SustainEffect = new class'X2Effect_FakeBleedout';
	SustainEffect.BuildPersistentEffect(1, true, true);
	SustainEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SustainEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.AdditionalAbilities.AddItem('FakeBleedoutTriggered');

	return Template;
}

static function X2DataTemplate CreateFakeBleedoutTrigger()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_Stunned                  StunEffect;
	local X2AbilityTrigger_EventListener    EventTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FakeBleedoutTriggered');

	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sustain";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	StunEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(8, 100, false); //99 turns
	StunEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.StunnedFriendlyName, class'X2StatusEffects'.default.StunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun");
	StunEffect.EffectRemovedFn = BleedoutFn;
	Template.AddTargetEffect(StunEffect);

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = class'X2Effect_FakeBleedout'.default.SustainEvent;
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self_VisualizeInGameState;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.PostActivationEvents.AddItem(class'X2Effect_FakeBleedout'.default.SustainTriggeredEvent);
		
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function BleedoutFn(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed)
{
	local XComGameState_Unit TargetUnit;
	//local X2EventManager EventManager;
	local int KillAmount;


	TargetUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	KillAmount = TargetUnit.GetCurrentStat(eStat_HP) + TargetUnit.GetCurrentStat(eStat_ShieldHP);


	TargetUnit.TakeEffectDamage(PersistentEffect, KillAmount, 0, 0, ApplyEffectParameters, NewGameState, false);
}

static function X2AbilityTemplate CreateIntimidate()
{
	local X2AbilityTemplate						Template;
	local X2Effect_CoveringFire                 CoveringEffect;

	Template = PurePassive('RM_Intimidate', "img:///UILibrary_DLC3Images.UIPerk_spark_intimidate", false, 'eAbilitySource_Perk', true);
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	CoveringEffect = new class'X2Effect_CoveringFire';
	CoveringEffect.BuildPersistentEffect(1, true, false, false);
	CoveringEffect.AbilityToActivate = 'RM_IntimidateTrigger';
	CoveringEffect.GrantActionPoint = 'intimidate';
	CoveringEffect.bPreEmptiveFire = false;
	CoveringEffect.bDirectAttackOnly = true;
	CoveringEffect.bOnlyDuringEnemyTurn = true;
	CoveringEffect.bUseMultiTargets = false;
	CoveringEffect.EffectName = 'IntimidateWatchEffect';
	Template.AddTargetEffect(CoveringEffect);

	Template.AdditionalAbilities.AddItem('RM_IntimidateTrigger');

	return Template;
}

static function X2AbilityTemplate CreateIntimidateTrigger()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Panicked						PanicEffect;
	local X2AbilityCost_ReserveActionPoints     ActionPointCost;
	local X2Condition_UnitEffects               UnitEffects;

	Template= new(None, string('RM_IntimidateTrigger')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_IntimidateTrigger');;;
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	Template.IconImage = "img:///UILibrary_DLC3Images.UIPerk_spark_intimidate";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.AllowedTypes.Length = 0;
	ActionPointCost.AllowedTypes.AddItem('intimidate');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AddShooterEffectExclusions();

	Template.AbilityToHitCalc = default.DeadEye;                //  the real roll is in the effect apply chance
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);

	PanicEffect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	PanicEffect.ApplyChanceFn = IntimidationApplyChance;
	PanicEffect.VisualizationFn = Intimidate_Visualization;
	Template.AddTargetEffect(PanicEffect);

	Template.CustomFireAnim = 'NO_Intimidate';
	Template.bShowActivation = true;
	Template.CinescriptCameraType = "Spark_Intimidate";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

function name IntimidationApplyChance(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	//  this mimics the panic hit roll without actually BEING the panic hit roll
	local XComGameState_Unit TargetUnit, SourceUnit;
	local name ImmuneName;
	local int AttackVal, DefendVal, TargetRoll, RandRoll;
	//local XComGameState_Item ArmorState;

	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (SourceUnit == none)
		SourceUnit = XComGameState_Unit(class'XComGameStateHistory'.static.GetGameStateHistory().GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (TargetUnit != none)
	{
		foreach class'X2AbilityToHitCalc_PanicCheck'.default.PanicImmunityAbilities(ImmuneName)
		{
			if (TargetUnit.FindAbility(ImmuneName).ObjectID != 0)
			{
				return 'AA_UnitIsImmune';
			}
		}
		AttackVal = SourceUnit.GetCurrentStat(eStat_Will);
		DefendVal = TargetUnit.GetCurrentStat(eStat_Will);
		TargetRoll = class'X2AbilityToHitCalc_PanicCheck'.default.BaseValue + AttackVal - DefendVal;
		RandRoll = (class'Engine'.static.GetEngine().SyncRand(100,string(Name)@string(GetStateName())@string(GetFuncName())));
		if (RandRoll < TargetRoll)
			return 'AA_Success';
	}

	return 'AA_EffectChanceFailed';
}

static function Intimidate_Visualization(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability Context;
	local X2AbilityTemplate	AbilityTemplate;

	if( EffectApplyResult != 'AA_Success' )
	{
		// pan to the panicking unit (but only if it isn't a civilian)
		Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
		if( (UnitState == none) || (Context == none) )
		{
			return;
		}

		AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), AbilityTemplate.LocMissMessage, '' , eColor_Good, class'UIUtilities_Image'.const.UnitStatus_Panicked);
	}
}
static function X2AbilityTemplate CreateMimeticSkin()
{
	local X2AbilityTemplate						Template;
	local X2Effect_RangerStealth                StealthEffect;
	//local X2AbilityCharges                      Charges;
	local X2AbilityTrigger_EventListener    EventTrigger;
	//local X2Condition_Visibility            CoverCondition;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_MimeticSkin');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stealth";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	// loot will also automatically trigger at the end of a move if it is possible
	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventTrigger.ListenerData.EventID = 'UnitMoveFinished';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_MimeticSkin');

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}
static function X2AbilityTemplate CreateLongJump()
{
	local X2AbilityTemplate Template;	
	local X2Effect_PersistentTraversalChange	JumpServosEffect;
	//local X2Effect_AdditionalAnimSets			IcarusAnimSet;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_LongJump');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	//Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_wraith";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_jetboot_module";

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityShooterConditions.AddItem( default.LivingShooterProperty );
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.AbilityToHitCalc = default.DeadEye;


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.bSkipPerkActivationActions = true; // we'll trigger related perks as part of the movement action

	// Give the unit the JumpUp traversal type
	JumpServosEffect = new class'X2Effect_PersistentTraversalChange';
	JumpServosEffect.BuildPersistentEffect( 1, true, true, false, eGameRule_PlayerTurnBegin );
	JumpServosEffect.SetDisplayInfo( ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText( ), Template.IconImage, true );
	JumpServosEffect.AddTraversalChange( eTraversal_WallClimb, true );
	JumpServosEffect.EffectName = 'MOCX_Agility';
	JumpServosEffect.DuplicateResponse = eDupe_Refresh;

	Template.AddTargetEffect( JumpServosEffect );


	return Template;
}



static function X2AbilityTemplate AddLauncherAbility()
{
	local X2AbilityTemplate					Template;
	local RM_Effect_UseGrenadeLauncher	AdvGLEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_GrenadeLauncher');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_grenade_flash";  // shouldn't ever display
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	AdvGLEffect = new class'RM_Effect_UseGrenadeLauncher'; //this is basically DerBk's work anyway
	Template.AddTargetEffect(AdvGLEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}