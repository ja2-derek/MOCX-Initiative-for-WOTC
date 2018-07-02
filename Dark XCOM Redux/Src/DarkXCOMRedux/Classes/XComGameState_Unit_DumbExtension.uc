class XComGameState_Unit_DumbExtension extends XComGameState_Unit;

//this exists to edit one variable of XComGameState_Unit

//that's it

//nothing more

//jake plz


static function RemoveAllLoot(XComGameState_Unit Unit)
{
	Unit.PendingLoot.LootToBeCreated.Length = 0;
}