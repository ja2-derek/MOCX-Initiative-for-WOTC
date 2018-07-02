class X2Effect_OddNerf extends X2Effect_Persistent config(GameCore);

var float ExplosiveDamageReduction;

function int ModifyDamageFromDestructible(XComGameState_Destructible DestructibleState, int IncomingDamage, XComGameState_Unit TargetUnit, XComGameState_Effect EffectState)
{
	//	destructible damage is always considered to be explosive
	local int DamageMod;

	DamageMod = -int(float(IncomingDamage) * ExplosiveDamageReduction);

	return DamageMod;
}


defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
