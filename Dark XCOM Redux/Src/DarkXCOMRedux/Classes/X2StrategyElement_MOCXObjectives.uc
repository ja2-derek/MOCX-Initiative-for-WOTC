//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_DLC_Day60Objectives.uc
//  AUTHOR:  Joe Weinhoffer
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2StrategyElement_MOCXObjectives extends X2StrategyElement
	dependson(XComGameState_ObjectivesList);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Objectives;

	Objectives.AddItem(CreateMOCXHiddenBeatTemplate());

	/////////////// DLC //////////////////
	Objectives.AddItem(CreateMOCXQuestStartTemplate());
	Objectives.AddItem(CreateMOCXQuestMidOneTemplate());
	Objectives.AddItem(CreateMOCXQuestMidTwoTemplate());

	Objectives.AddItem(CreateMOCXOffsiteTemplate());
	Objectives.AddItem(CreateMOCXTrainingTemplate());
	Objectives.AddItem(CreateMOCXHQTemplate());

	return Objectives;
}

static function X2DataTemplate CreateMOCXHiddenBeatTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_HiddenBeat');
	Template.bMainObjective = true;
	Template.bNeverShowObjective = true;

	Template.NextObjectives.AddItem('MOCX_QuestStart');

	Template.CompletionEvent = 'MOCXRevealed';
	
	return Template;
}

static function X2DataTemplate CreateMOCXQuestStartTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_QuestStart');
	Template.bMainObjective = true;
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Contact_Resistance";


	Template.NextObjectives.AddItem('MOXC_QuestMidOne');
	Template.NextObjectives.AddItem('MOCX_OffsiteBackups');

	Template.RevealEvent = '';
	//Template.NextObjectives.AddItem('DLC_KillViperKing');
	//Template.NextObjectives.AddItem('N_ViperKingReturns');
	Template.CompletionEvent = 'MOCX_QuestStart';
	//Template.CompleteObjectiveFn = FlagDLCCompleted;

	return Template;
}
static function X2DataTemplate CreateMOCXQuestMidOneTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_QuestMidOne');
	Template.bMainObjective = true;
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Contact_Resistance";

	Template.NextObjectives.AddItem('MOCX_QuestMidTwo');
	Template.NextObjectives.AddItem('MOCX_TrainingRaid');

	Template.RevealEvent = '';
	//Template.NextObjectives.AddItem('DLC_KillViperKing');
	//Template.NextObjectives.AddItem('N_ViperKingReturns');
	Template.CompletionEvent = 'MOCXTraining_Revealed';
	//Template.CompleteObjectiveFn = FlagDLCCompleted;

	return Template;
}


static function X2DataTemplate CreateMOCXQuestMidTwoTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_QuestMidTwo');
	Template.bMainObjective = true;
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Contact_Resistance";

	Template.NextObjectives.AddItem('MOCX_SabotageHQ');

	Template.RevealEvent = '';
	//Template.NextObjectives.AddItem('DLC_KillViperKing');
	//Template.NextObjectives.AddItem('N_ViperKingReturns');
	Template.CompletionEvent = 'MOCXHQ_Revealed';
	//Template.CompleteObjectiveFn = FlagDLCCompleted;

	return Template;
}


static function X2DataTemplate CreateMOCXHQTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_SabotageHQ');
	Template.bMainObjective = true;
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Sky_Tower";


	Template.RevealEvent = '';
	//Template.NextObjectives.AddItem('DLC_KillViperKing');
	//Template.NextObjectives.AddItem('N_ViperKingReturns');
	Template.CompletionEvent = 'MOCXHQ_Destroyed';
	//Template.CompleteObjectiveFn = FlagDLCCompleted;

	return Template;
}


static function X2DataTemplate CreateMOCXOffsiteTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_OffsiteBackups');
	Template.bMainObjective = true;
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Blacksite";


	Template.RevealEvent = '';
	//Template.NextObjectives.AddItem('DLC_KillViperKing');
	//Template.NextObjectives.AddItem('N_ViperKingReturns');
	Template.CompletionEvent = 'MOCXOffsite_Victory';
	//Template.CompleteObjectiveFn = FlagDLCCompleted;

	return Template;
}


static function X2DataTemplate CreateMOCXTrainingTemplate()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'MOCX_TrainingRaid');
	Template.bMainObjective = true;
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Alien_Encryption";


	Template.RevealEvent = '';
	//Template.NextObjectives.AddItem('DLC_KillViperKing');
	//Template.NextObjectives.AddItem('N_ViperKingReturns');
	Template.CompletionEvent = 'MOCXTraining_Victory';
	//Template.CompleteObjectiveFn = FlagDLCCompleted;

	return Template;
}