class X2Effect_OddNerf extends X2Effect_Persistent config(GameCore);

var float ExplosiveDamageReduction;

function int ModifyDamageFromDestructible(XComGameState_Destructible DestructibleState, int IncomingDamage, XComGameState_Unit TargetUnit, XComGameState_Effect EffectState)
{
	//	destructible damage is always considered to be explosive
	local int DamageMod;


	if (DestructibleState.SpawnedDestructibleArchetype == class'X2Ability_ReaperAbilitySet'.default.ClaymoreDestructibleArchetype || DestructibleState.SpawnedDestructibleArchetype == class'X2Ability_ReaperAbilitySet'.default.ShrapnelDestructibleArchetype) // ignore claymore damage
	{
		return 0;
	}

	DamageMod = -int(float(IncomingDamage) * ExplosiveDamageReduction);

	return DamageMod;
}


defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
