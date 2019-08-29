within AixLib.Fluid.DistrictHeatingCooling.Demands.ClosedLoop;
model PumpControlledwithHP_RE_C "Substation model for  low-temperature networks for buildings with 
  heat pump and chiller"

      replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    "Medium model for water"
      annotation (choicesAllMatching = true);
      replaceable package MediumBuilding = AixLib.Media.Water
      "Medium in the building heating system"
      annotation (choicesAllMatching = true);

    final parameter Medium.ThermodynamicState sta_default = Medium.setState_pTX(
    T=Medium.T_default,
    p=Medium.p_default,
    X=Medium.X_default[1:Medium.nXi]) "Medium state at default properties";
    final parameter Modelica.SIunits.SpecificHeatCapacity cp_default =   Medium.specificHeatCapacityCp(sta_default)
                                                                                  "Cp-value of Water";

    parameter Modelica.SIunits.HeatFlowRate heatDemand_max "maximum heat demand for scaling of heatpump in Watt";
//    parameter Modelica.SIunits.HeatFlowRate coolingDemand_max=-5000
//                                                              "maximum cooling demand for scaling of chiller in Watt (negative values)";
    parameter Modelica.SIunits.Temperature T_supplyHeating "set temperature of supply heating";
    parameter Modelica.SIunits.Temperature T_supplyCooling "set temperature of supply heating";

 //   parameter Modelica.SIunits.Temperature deltaT_heatingSet "set temperature difference for heating on the site of building";
 //   parameter Modelica.SIunits.Temperature deltaT_coolingSet "set temperature difference for cooling on the building site";

    parameter Modelica.SIunits.Pressure dp_nominal=400000                  "nominal pressure drop";

    parameter Modelica.SIunits.MassFlowRate m_flow_nominal=(heatDemand_max)/
      cp_default/10
    "Nominal mass flow rate";

public
  Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
        Medium)
    "Fluid connector for connecting the substation to the warm line of the network"
    annotation (Placement(transformation(extent={{-270,-10},{-250,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium =
        Medium)
    "Fluid connector for connecting the substation to the cold line of the network"
    annotation (Placement(transformation(extent={{210,-10},{230,10}}),
        iconTransformation(extent={{210,-10},{230,10}})));
  AixLib.Fluid.HeatPumps.Carnot_TCon_RE heaPum(redeclare package Medium2 = Medium,
      redeclare package Medium1 = MediumBuilding,
    show_T=true,
    dTEva_nominal=-10,
    dTCon_nominal=10,
    etaCarnot_nominal=0.5,
    Q_heating_nominal=heatDemand_max,
    use_eta_Carnot_nominal=true,
    dp1_nominal=30000,
    dp2_nominal=30000,
    m2_flow_nominal=1,
    m1_flow_nominal=m_flow_nominal,
    Q_cooling_nominal=-15000,
    TEva_nominal=283.15)
    annotation (Placement(transformation(extent={{8,4},{-12,-16}})));
  Modelica.Blocks.Interfaces.RealInput[2] Q_flow_input
  "Input for heat demand profile of substation"
    annotation (Placement(transformation(extent={{-280,-60},{-240,-20}}),
        iconTransformation(extent={{232,76},{192,116}})));

  Movers.FlowControlled_m_flow fan5(redeclare package Medium =MediumBuilding,
      inputType=AixLib.Fluid.Types.InputType.Continuous,
    m_flow_nominal=m_flow_nominal,
    allowFlowReversal=false,
    y_start=1,
    m_flow_start=m_flow_nominal,
    m_flow_small=0,
    p_start=200000000,
    T_start=308.15,
    use_inputFilter=true)                                              annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=0,
        origin={-104,-36})));
  Modelica.Blocks.Math.Gain gain(k=-1)
    annotation (Placement(transformation(extent={{-260,-90},{-240,-70}})));
  Sensors.TemperatureTwoPort senTem1(redeclare package Medium = MediumBuilding,tau=0,
    m_flow_nominal=m_flow_nominal,
    T_start=308.15)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=270,
        origin={-136,-60})));
  Modelica.Blocks.Sources.RealExpression realExpression2(y=m_flow_nominal)
    annotation (Placement(transformation(extent={{-72,-72},{-92,-52}})));
  Delays.DelayFirstOrder del1(
    redeclare package Medium = Medium,
    tau=600,
    m_flow_nominal=2*m_flow_nominal,
    T_start=283.15,
    nPorts=2)
    annotation (Placement(transformation(extent={{140,12},{160,32}})));
  Sources.FixedBoundary bou(
    redeclare package Medium = MediumBuilding,
    use_p=true,
    use_T=false,
    nPorts=1)
    annotation (Placement(transformation(extent={{-164,-30},{-144,-10}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=293.15)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-6,-210})));

  Sensors.TemperatureTwoPort senTem(redeclare package Medium = Medium,m_flow_nominal=2*m_flow_nominal, tau=0,
    T_start=283.15)
    annotation (Placement(transformation(extent={{46,-10},{66,10}})));
  Sources.FixedBoundary bou1(redeclare package Medium = Medium,          use_T=false,
    nPorts=1)
    annotation (Placement(transformation(extent={{-182,14},{-162,34}})));
  Sensors.TemperatureTwoPort senTem2(redeclare package Medium =Medium,allowFlowReversal=false, tau=0,
    m_flow_nominal=2*m_flow_nominal)
    annotation (Placement(transformation(extent={{-78,-10},{-58,10}})));
  MixingVolumes.MixingVolume vol(redeclare package Medium = MediumBuilding,
    V=0.15,
    nPorts=2,
    m_flow_nominal=0.15,
    m_flow_small=0.001,
    allowFlowReversal=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
    T_start=308.15)                                                          annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={186,-174})));
  Sensors.TemperatureTwoPort senTem4(redeclare package Medium = MediumBuilding,                               tau=0,
    m_flow_nominal=0.25,
    allowFlowReversal=false,
    T_start=308.15)
    annotation (Placement(transformation(extent={{110,-206},{130,-186}})));
  Sensors.TemperatureTwoPort senTem5(redeclare package Medium =MediumBuilding,                               tau=0,
    m_flow_nominal=0.25,
    allowFlowReversal=false,
    T_start=308.15)
    annotation (Placement(transformation(extent={{132,-156},{112,-176}})));
  Storage.StratifiedEnhancedInternalHex tan(
    redeclare package Medium = MediumBuilding,
    redeclare package MediumHex = MediumBuilding,
    dIns=0.0762,
    m_flow_nominal=m_flow_nominal,
    mHex_flow_nominal=m_flow_nominal,
    allowFlowReversal=false,
    m_flow_small=0.0001,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
   energyDynamicsHex=Modelica.Fluid.Types.Dynamics.FixedInitial,
    nSeg=4,
    Q_flow_nominal=m_flow_nominal*cp_default*30,
    kIns=0.04,
    tau=1,
    hexSegMult=2,
    dExtHex=0.025,
    r_nominal=0.5,
    dpHex_nominal=2500,
    allowFlowReversalHex=false,
    hHex_b=0.5,
    hTan=2,
    hHex_a=1.5,
    VTan=0.4,
    T_start=308.15,
    TTan_nominal=306.15,
    THex_nominal=338.15)
            annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={0,-170})));
  Sources.FixedBoundary bou2(redeclare package Medium =
        MediumBuilding, nPorts=1)
    annotation (Placement(transformation(extent={{126,-146},{106,-126}})));
  Movers.FlowControlled_m_flow fan1(
    redeclare package Medium = MediumBuilding,
    m_flow_nominal=0.25,
    use_inputFilter=true,
    allowFlowReversal=false,
    m_flow_small=0.0001,
    T_start=308.15)
    annotation (Placement(transformation(extent={{76,-156},{56,-176}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temperatureSensor
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-4,-136})));
  Sensors.TemperatureTwoPort senTem6(
    redeclare package Medium =MediumBuilding,
    m_flow_nominal=m_flow_nominal,
    tau=0,
    allowFlowReversal=false,
    T_start=308.15)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={92,-82})));
  Actuators.Valves.ThreeWayEqualPercentageLinear val(
   redeclare package Medium = MediumBuilding,
    energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
    T_start=308.15,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    riseTime=20,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=dp_nominal,
    R=10) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-134,-134})));
  Sensors.TemperatureTwoPort senTem7(
    redeclare package Medium = MediumBuilding,
    m_flow_nominal=m_flow_nominal,
    tau=0,
    T_start=308.15) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={-134,-166})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(
    pre_y_start=false,
    uLow=273.15 + 60,
    uHigh=273.15 + 65)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={12,-108})));
  Modelica.Blocks.Logical.Switch switch1
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={10,-62})));
  Modelica.Blocks.Sources.RealExpression realExpression4(y=273.15 + 65)
    annotation (Placement(transformation(extent={{50,-92},{30,-72}})));
  Modelica.Blocks.Sources.TimeTable T_set(table=[0,273.15 + 35; 7.0e+06,273.15
         + 35; 7.0e+06,273.15 + 35; 1.2e+07,273.15 + 35; 1.2e+07,273.15 + 10;
        2.2e+07,273.15 + 10; 2.2e+07,273.15 + 35; 2.7e+07,273.15 + 35; 2.7e+07,
        273.15 + 35; 3.1536e+07,273.15 + 35])
    annotation (Placement(transformation(extent={{-36,-84},{-16,-64}})));
  Modelica.Blocks.Sources.RealExpression realinput(y=senTem7.T + gain.y/(
        cp_default*m_flow_nominal))
    annotation (Placement(transformation(extent={{198,-60},{178,-40}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature1(T=293.15)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={184,-128})));
  Modelica.Blocks.Math.BooleanToReal opening annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-164,-126})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=Q_flow_input[2]/3600)
    annotation (Placement(transformation(extent={{96,-192},{76,-172}})));
  Movers.FlowControlled_m_flow fan(
     dp_nominal= dp_nominal,
     redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_small=0.0001,
    use_inputFilter=true,
    y_start=1,
    m_flow_nominal=2,
    m_flow_start=1)
    annotation (Placement(transformation(extent={{-142,-8},{-122,12}})));
  Modelica.Blocks.Sources.RealExpression realExpression5(y=1)
    annotation (Placement(transformation(extent={{-92,16},{-112,36}})));
  Sources.FixedBoundary bou3(
  redeclare package Medium =MediumBuilding,
  nPorts=1)
    annotation (Placement(transformation(extent={{-162,-234},{-142,-214}})));
  Sources.MassFlowSource_T boundary(
    redeclare package Medium =MediumBuilding,
    use_m_flow_in=true,
    use_T_in=true,
    nPorts=1)
    annotation (Placement(transformation(extent={{144,-48},{124,-28}})));
  Sensors.MassFlowRate HZ(redeclare package Medium =MediumBuilding) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-136,-196})));
  Modelica.Blocks.Sources.RealExpression realExpression1(y=HZ.m_flow)
    annotation (Placement(transformation(extent={{196,-38},{176,-18}})));
  Utilities.Sensors.EnergyMeter con_HM annotation (Placement(transformation(
        extent={{-6,-8},{6,8}},
        rotation=90,
        origin={-54,52})));
  Utilities.Sensors.EnergyMeter eva_HM annotation (Placement(transformation(
        extent={{-6,-8},{6,8}},
        rotation=90,
        origin={-6,52})));
  Utilities.Sensors.FuelCounter fuelCounter annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-30,52})));
  FixedResistances.Junction jun(redeclare package Medium =MediumBuilding,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    dp_nominal={0,0,0},
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={2,-2,2})
    annotation (Placement(transformation(extent={{102,-44},{82,-24}})));
equation

  //Power Consumptin Calculation
  //connect(pumpCooling.P, sum1.u[3]);
  //connect(pumpHeating.P, sum1.u[4]);

  connect(heaPum.port_b2, senTem.port_a) annotation (Line(points={{8,0},{46,0}},
                              color={0,127,255}));
  connect(senTem2.port_b, heaPum.port_a2) annotation (Line(points={{-58,0},{-12,
          0}},                       color={0,127,255}));
  connect(realExpression2.y, fan5.m_flow_in) annotation (Line(points={{-93,-62},
          {-98,-62},{-98,-48},{-104,-48}}, color={0,0,127}));
  connect(heaPum.port_b1, fan5.port_a) annotation (Line(points={{-12,-12},{-56,-12},
          {-56,-36},{-94,-36}},  color={0,127,255}));
  connect(fan5.port_b, senTem1.port_a) annotation (Line(points={{-114,-36},{-136,
          -36},{-136,-50}},            color={0,127,255}));
  connect(tan.heaPorSid, fixedTemperature.port) annotation (Line(points={{-8.88178e-16,
          -175.6},{-6,-175.6},{-6,-200}},
                                    color={191,0,0}));
  connect(bou.ports[1], fan5.port_a) annotation (Line(points={{-144,-20},{-94,
          -20},{-94,-36}},                   color={0,127,255}));
  connect(senTem4.port_b, vol.ports[1]) annotation (Line(points={{130,-196},{176,
          -196},{176,-172}}, color={0,127,255}));
  connect(vol.ports[2], senTem5.port_a) annotation (Line(points={{176,-176},{
          144,-176},{144,-166},{132,-166}},      color={0,127,255}));
  connect(tan.heaPorVol[1], temperatureSensor.port) annotation (Line(points={{0.45,
          -170},{-4,-170},{-4,-146}},              color={191,0,0}));
  connect(tan.portHex_b, senTem6.port_a) annotation (Line(points={{8,-160},{8,
          -134},{92,-134},{92,-92}},             color={0,127,255}));
  connect(senTem1.port_b, val.port_2) annotation (Line(points={{-136,-70},{-136,
          -124},{-134,-124}},            color={0,127,255}));
  connect(val.port_1, senTem7.port_a) annotation (Line(points={{-134,-144},{-134,
          -156}},                         color={0,127,255}));
  connect(temperatureSensor.T, hysteresis.u) annotation (Line(points={{-4,-126},
          {12,-126},{12,-120}},              color={0,0,127}));
  connect(fixedTemperature1.port, vol.heatPort) annotation (Line(points={{184,-138},
          {184,-164},{186,-164}},            color={191,0,0}));
  connect(heaPum.TSet, switch1.y)
    annotation (Line(points={{10,-15},{10,-51}}, color={0,0,127}));
  connect(realExpression4.y, switch1.u3)
    annotation (Line(points={{29,-82},{18,-82},{18,-74}}, color={0,0,127}));
  connect(T_set.y, switch1.u1)
    annotation (Line(points={{-15,-74},{2,-74}}, color={0,0,127}));
  connect(hysteresis.y, switch1.u2) annotation (Line(points={{12,-97},{12,-84},{
          10,-84},{10,-74}}, color={255,0,255}));
  connect(tan.portHex_a, val.port_3) annotation (Line(points={{3.8,-160},{4,-160},
          {4,-152},{-124,-152},{-124,-134}}, color={0,127,255}));

  connect(opening.y, val.y) annotation (Line(points={{-153,-126},{-150,-126},{-150,
          -134},{-146,-134}}, color={0,0,127}));

  connect(Q_flow_input[1], gain.u) annotation (Line(points={{-260,-50},{-262,-50},
          {-262,-80},{-262,-80}}, color={0,0,127}));
  connect(hysteresis.y, opening.u) annotation (Line(points={{12,-97},{12,-106},
          {-176,-106},{-176,-126}}, color={255,0,255}));
  connect(fan.port_b, senTem2.port_a) annotation (Line(points={{-122,2},{-100,2},
          {-100,0},{-78,0}}, color={0,127,255}));
  connect(bou1.ports[1], fan.port_a) annotation (Line(points={{-162,24},{-142,24},
          {-142,2}}, color={0,127,255}));
  connect(realExpression5.y, fan.m_flow_in) annotation (Line(points={{-113,26},
          {-122,26},{-122,28},{-132,28},{-132,14}}, color={0,0,127}));
  connect(senTem.port_b, del1.ports[1])
    annotation (Line(points={{66,0},{148,0},{148,12}}, color={0,127,255}));
  connect(del1.ports[2], port_b) annotation (Line(points={{152,12},{152,12},{
          152,0},{220,0}}, color={0,127,255}));
  connect(port_a, fan.port_a) annotation (Line(points={{-260,0},{-202,0},{-202,
          2},{-142,2}}, color={0,127,255}));
  connect(senTem7.port_b, HZ.port_a) annotation (Line(points={{-134,-176},{-136,
          -176},{-136,-186}}, color={0,127,255}));
  connect(HZ.port_b, bou3.ports[1]) annotation (Line(points={{-136,-206},{-136,-224},
          {-142,-224}}, color={0,127,255}));
  connect(realinput.y, boundary.T_in)
    annotation (Line(points={{177,-50},{146,-50},{146,-34}}, color={0,0,127}));
  connect(realExpression1.y, boundary.m_flow_in) annotation (Line(points={{175,-28},
          {162,-28},{162,-30},{146,-30}}, color={0,0,127}));
  connect(senTem5.port_b, fan1.port_a)
    annotation (Line(points={{112,-166},{76,-166}}, color={0,127,255}));
  connect(fan1.port_b, tan.port_a)
    annotation (Line(points={{56,-166},{0,-166},{0,-160}}, color={0,127,255}));
  connect(realExpression.y, fan1.m_flow_in)
    annotation (Line(points={{75,-182},{66,-182},{66,-178}}, color={0,0,127}));
  connect(bou2.ports[1], fan1.port_a) annotation (Line(points={{106,-136},{98,
          -136},{98,-166},{76,-166}}, color={0,127,255}));
  connect(tan.port_b, senTem4.port_a) annotation (Line(points={{0,-180},{0,-196},
          {110,-196}}, color={0,127,255}));
  connect(eva_HM.p, heaPum.QEva_flow) annotation (Line(points={{-6,46.4},{-8,
          46.4},{-8,3},{-13,3}}, color={0,0,127}));
  connect(heaPum.P, fuelCounter.fuel_in) annotation (Line(points={{-13,-6},{-16,
          -6},{-16,-4},{-30,-4},{-30,42}}, color={0,0,127}));
  connect(heaPum.QCon_flow, con_HM.p) annotation (Line(points={{-13,-15},{-54,
          -15},{-54,46.4}}, color={0,0,127}));
  connect(senTem6.port_b, jun.port_3)
    annotation (Line(points={{92,-72},{92,-44}}, color={0,127,255}));
  connect(boundary.ports[1], jun.port_1) annotation (Line(points={{124,-38},{114,
          -38},{114,-34},{102,-34}}, color={0,127,255}));
  connect(jun.port_2, heaPum.port_a1) annotation (Line(points={{82,-34},{22,-34},
          {22,-12},{8,-12}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-260,-280},
            {220,60}}),  graphics={
        Rectangle(
          extent={{-260,160},{220,-180}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-154,32},{118,-174}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.HorizontalCylinder),
        Polygon(
          points={{-154,32},{-30,142},{118,32},{-154,32}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-102,4},{-56,-50}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-36,-100},{4,-174}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,2},{58,-54}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-260,-280},{220,60}})),
    Documentation(revisions="<html>
<ul>
<li><i>August 09, 2018</i> ,by Tobias Blacha:<br/>
Implemented </li>
</ul>
</html>", info="<html>
<p>Substation model for bidirctional low-temperature networks for buildings with heat pump and chiller. In the case of simultaneous cooling and heating demands, the return flows are used as supply flows for the other application. The mass flows are controlled equation-based. The mass flows are calculated using the heating and cooling demands and the specified temperature differences between flow and return (network side).</p>
</html>"));
end PumpControlledwithHP_RE_C;
