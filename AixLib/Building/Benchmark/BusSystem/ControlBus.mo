within AixLib.Building.Benchmark.BusSystem;
expandable connector ControlBus
  "Control bus that is adapted to the signals connected to it"
  extends Modelica.Icons.SignalBus;
  import SI = Modelica.SIunits;
  // Temperatur
  SI.Temp_K HotWater_TTop "Temperatur at the top of the hotwater-bufferstorage";
  SI.Temp_K HotWater_TBottom "Temperatur at the bottom of the hotwater-bufferstorage";
  SI.Temp_K WarmWater_TTop "Temperatur at the top of the warmwater-bufferstorage";
  SI.Temp_K WarmWater_TBottom "Temperatur at the bottom of the warmwater-bufferstorage";
  SI.Temp_K ColdWater_TTop "Temperatur at the top of the coldwater-bufferstorage";
  SI.Temp_K ColdWater_TBottom "Temperatur at the bottom of the coldwater-bufferstorage";

  // Pump dp
  Real Pump_Hotwater_dp "Prescribed pressure rise of hotwaterpump";
  Real Pump_Warmwater_dp "Prescribed pressure rise of warmwaterpump";
  Real Pump_Coldwater_dp "Prescribed pressure rise of coldwaterpump";
  Real Pump_Coldwater_heatpump_dp "Prescribed pressure rise of coldwaterpump on heatpumpside";
  Real Pump_Warmwater_heatpump_dp "Prescribed pressure rise of warmwaterpump on heatpumpside";
  Real Pump_Aircooler_dp "Prescribed pressure rise of aircoolerpump";
  Real Pump_Hotwater_CHP_dp "Prescribed pressure rise of aircoolerpump";

  // Fan m_flow
  Real Fan_Aircooler "Massflow of the Aircoolerfan";
  Real Fan_RLT "Massflow of the RLT-fan";

  // Valvepositions
  Real Valve1 "Valveposition of Valve1 (Coldwater geothermalprobe)";
  Real Valve2 "Valveposition of Valve2 (Coldwater coldwater bufferstorage)";
  Real Valve3 "Valveposition of Valve3 (Coldwater heatexchanger)";
  Real Valve4 "Valveposition of Valve4 (Warmwater heatexchanger)";
  Real Valve5 "Valveposition of Valve5 (Warmwater warmwater bufferstorage)";
  Real Valve6 "Valveposition of Valve6 (Hotwater boiler)";
  Real Valve7 "Valveposition of Valve7 (Hotwater warmwater bufferstorage)";
  Real Valve8 "Valveposition of Valve8 (Aircooler)";

  Real Valve_WarmCold_OpenPlanOffice_1 "Valveposition of Valve 1 for warm or cold of the openplanoffice";
  Real Valve_WarmCold_OpenPlanOffice_2 "Valveposition of Valve 2 for warm or cold of the openplanoffice";

  // On/Off components
  Boolean OnOff_heatpump "On/Off Signal for the heatpump";
  Boolean OnOff_CHP   "On/Off Signal for the CHP";
  Boolean OnOff_boiler "On/Off Signal for the boiler";

  // Setpoints for components
  Real ElSet_CHP "Electrical Power Setpoint CHP";
  Real TSet_CHP "Temperatur Setpoint CHP";
  Real TSet_boiler "Temperatur Setpoint boiler";

  // Moisterlevel
  Real X_OpenPlanOffice "Moisterlevel for the RLT of the openplanoffice";
end ControlBus;
