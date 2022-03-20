local modName = "mod_fatigue_recovery"
::mods_registerMod(modName, 1.1)

::mods_queue(null, null, function()
{
	::mods_registerJS("mod_fatigue_recovery.js")
	::mods_hookExactClass("entity/tactical/actor", function(o){
		o.getFatigueRecovery <- function(){
			local diffFromNormal = this.m.CurrentProperties.FatigueRecoveryRate - 15; //increase/decrease based on traits, wounds, enemies with more than default
			local baseRecovery = 9 + diffFromNormal; 
			local baseFatigue = this.m.CurrentProperties.Stamina;
			local fatigueFromPercentage = (baseFatigue/10).tointeger();
			local totalRecovery = baseRecovery + fatigueFromPercentage;
			return totalRecovery;
		}
		local onTurnStart = o.onTurnStart
		o.onTurnStart = function(){
			if (!this.isAlive())
			{
				return onTurnStart();
			}
			local oldFatigue = this.m.Fatigue;
			local result = onTurnStart();
			this.m.Fatigue = oldFatigue;
			local totalRecovery = this.getFatigueRecovery();
			local p = this.m.CurrentProperties;

			this.m.Fatigue = this.Math.max(0, this.Math.min(this.getFatigueMax() - totalRecovery, this.Math.max(0, this.m.Fatigue - this.Math.max(0, totalRecovery) * p.FatigueRecoveryRateMult)));
			this.m.PreviewFatigue = this.m.Fatigue;
			return result;
		}
	})
	::mods_hookNewObject("ui/global/data_helper", function(o){
		local addStatsToUIData = o.addStatsToUIData;
		o.addStatsToUIData = function(_entity, _target)
		{
			addStatsToUIData(_entity, _target);
			_target.fatigueRecovery <- _entity.getFatigueRecovery();
		}
	})

	::mods_hookExactClass("ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function(o){
		local convertEntityToUIData = o.convertEntityToUIData;
		o.convertEntityToUIData = function(_entity, isLastEntity = false)
		{
			local result = convertEntityToUIData(_entity, isLastEntity);
			result.fatigueRecovery <- _entity.getFatigueRecovery();
			return result;
		}
	})


	::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function(o){

		local general_queryUIElementTooltipData = o.general_queryUIElementTooltipData
		o.general_queryUIElementTooltipData <- function( _entityId, _elementId, _elementOwner ){
			if (_elementId != "character-stats.Fatigue")
			{
				return general_queryUIElementTooltipData( _entityId, _elementId, _elementOwner);
			}
			local result = general_queryUIElementTooltipData( _entityId, _elementId, _elementOwner);

			result[1]["text"] = "Fatigue is gained for every action, like moving or using skills, and when being hit in combat or dodging in melee. It is reduced at a rate of 9 plus (maximum fatigue / 10), plus traits and wounds, per turn. The current recovery rate is indicated in the brackets. If a character accumulates too much fatigue they may need to rest a turn (i.e. do nothing) before being able to use more specialized skills again.";
			return result;
		}
	})
})