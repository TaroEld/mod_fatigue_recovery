ProgressbarValueIdentifier["FatigueRecovery"] = "fatigueRecovery"
var old_setProgressbarValue = CharacterScreenStatsModule.prototype.setProgressbarValue
CharacterScreenStatsModule.prototype.setProgressbarValue = function (_progressbarDiv, _data, _valueKey, _valueMaxKey, _labelKey)
{
    old_setProgressbarValue.call(this, _progressbarDiv, _data, _valueKey, _valueMaxKey, _labelKey)
    if (ProgressbarValueIdentifier.FatigueRecovery in _data && _valueKey == ProgressbarValueIdentifier.Fatigue)
    {
        _progressbarDiv.changeProgressbarLabel('' + _data[ProgressbarValueIdentifier.Fatigue] + ' / ' + _data[ProgressbarValueIdentifier.FatigueMax] + ' (' + _data[ProgressbarValueIdentifier.FatigueRecovery] + ')');
    }
};


var old_updateStatsPanel = TacticalScreenTurnSequenceBarModule.prototype.updateStatsPanel
TacticalScreenTurnSequenceBarModule.prototype.updateStatsPanel = function (_data)
{
    old_updateStatsPanel.call(this, _data)
    if (ProgressbarValueIdentifier.FatigueRecovery in _data)
    {
       this.mLeftStatsRows.Fatigue.ProgressbarLabel.html('' + _data[ProgressbarValueIdentifier.Fatigue] + ' / ' + _data[ProgressbarValueIdentifier.FatigueMax] + ' (' + _data[ProgressbarValueIdentifier.FatigueRecovery] + ')');
    }
}
