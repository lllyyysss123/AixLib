﻿within AixLib.Fluid.BoilerCHP.ModularCHP;
model ModularCHP_DynamicHX_EASY_EXPERIMENTAL
  "Modular combined heat and power system model"
  import AixLib;

  replaceable package Medium_Fuel =
      AixLib.DataBase.CHP.ModularCHPEngineMedia.NaturalGasMixture_TypeAachen
                                                                    constrainedby
    DataBase.CHP.ModularCHPEngineMedia.CHPCombustionMixtureGasNasa
                                annotation(choicesAllMatching=true);
protected
  replaceable package Medium_Air =
      AixLib.DataBase.CHP.ModularCHPEngineMedia.EngineCombustionAir
                                                               constrainedby
    DataBase.CHP.ModularCHPEngineMedia.EngineCombustionAir
                         annotation(choicesAllMatching=true);

  replaceable package Medium_Exhaust =
      DataBase.CHP.ModularCHPEngineMedia.CHPFlueGasLambdaOnePlus  constrainedby
    DataBase.CHP.ModularCHPEngineMedia.CHPCombustionMixtureGasNasa
                                 annotation(choicesAllMatching=true);
public
  replaceable package Medium_Coolant = Modelica.Media.Air.DryAirNasa
                                                           constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true);

  replaceable package Medium_HeatingCircuit =
      Modelica.Media.CompressibleLiquids.LinearColdWater   constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);

  parameter
    AixLib.DataBase.CHP.ModularCHPEngineData.CHPEngDataBaseRecord
    CHPEngineModel=DataBase.CHP.ModularCHPEngineData.CHP_Kirsch_L4_12()
    "CHP engine data for calculations"
    annotation (choicesAllMatching=true, Dialog(group="Unit properties"));

  parameter AixLib.Fluid.BoilerCHP.Data.ModularCHP.EngineMaterialData EngMat=
      AixLib.Fluid.BoilerCHP.Data.ModularCHP.EngineMaterial_CastIron()
    "Thermal engine material data for calculations"
    annotation (choicesAllMatching=true, Dialog(group="Unit properties"));

  inner Modelica.Fluid.System system(p_ambient=p_amb, T_ambient=T_amb)
    annotation (Placement(transformation(extent={{-100,-100},{-84,-84}})));

  parameter Modelica.SIunits.Temperature T_amb=293.15
    "Default ambient temperature"
    annotation (Dialog(group="Ambient Parameters"));
  parameter Modelica.SIunits.AbsolutePressure p_amb=101325
    "Default ambient pressure" annotation (Dialog(group="Ambient Parameters"));
  Modelica.SIunits.Temperature T_Ret=temRetFlo.T "Coolant return temperature";
  Modelica.SIunits.Temperature T_Sup=temSupFlo.T "Coolant supply temperature";
  Modelica.SIunits.Power Q_Therm_th=cHP_PowerUnit.Q_Therm "Thermal power output of the CHP unit to the coolant media";
  Modelica.SIunits.Power Q_Therm=coolantHex.Q2_flow "Effective thermal power output of the CHP unit to the heating circuit";
  Modelica.SIunits.Power P_Mech=cHP_PowerUnit.P_Mech "Mechanical power output of the CHP unit";
  Modelica.SIunits.Power P_El=cHP_PowerUnit.P_El "Electrical power output of the CHP unit";
  Modelica.SIunits.Power P_Fuel=cHP_PowerUnit.P_Fuel "CHP fuel expenses";
  Modelica.SIunits.Power Q_TotUnused=cHP_PowerUnit.Q_TotUnused "Total heat error of the CHP unit";
 // Modelica.SIunits.Power Q_ExhUnused=exhaustHeatExchanger.volExhaust.ports_H_flow[1]+exhaustHeatExchanger.volExhaust.ports_H_flow[2]+exhaustHeatExchanger.volExhaust.heatPort.Q_flow "Total exhaust heat error";
  Modelica.SIunits.MassFlowRate m_flow_CO2=cHP_PowerUnit.m_flow_CO2
    "CO2 emission output rate";
  Modelica.SIunits.MassFlowRate m_flow_Fue=cHP_PowerUnit.m_flow_Fue
    "Fuel consumption rate of CHP unit";
  type SpecificEmission=Real(final unit="g/(kW.h)", min=0.0001);
  SpecificEmission b_CO2=cHP_PowerUnit.b_CO2 "Specific CO2 emissions per kWh (heat and power)";
  SpecificEmission b_e=cHP_PowerUnit.b_e "Specific fuel consumption per kWh (heat and power)";
  Real FueUtiRate = cHP_PowerUnit.FueUtiRate "Fuel utilization rate of the CHP unit";
  Real PowHeatRatio = cHP_PowerUnit.PowHeatRatio "Power to heat ration of the CHP unit";
  Real eta_Therm = cHP_PowerUnit.eta_Therm "Thermal efficiency of the CHP unit";
  Real eta_Mech = cHP_PowerUnit.eta_Mech "Mechanical efficiency of the CHP unit";
  Real eta_El = cHP_PowerUnit.eta_El "Mechanical efficiency of the CHP unit";

  parameter Real s_til=abs((cHP_PowerUnit.inductionMachine.s_nominal*(
      cHP_PowerUnit.inductionMachine.M_til/cHP_PowerUnit.inductionMachine.M_nominal)
       + cHP_PowerUnit.inductionMachine.s_nominal*sqrt(abs(((cHP_PowerUnit.inductionMachine.M_til
      /cHP_PowerUnit.inductionMachine.M_nominal)^2) - 1 + 2*cHP_PowerUnit.inductionMachine.s_nominal
      *((cHP_PowerUnit.inductionMachine.M_til/cHP_PowerUnit.inductionMachine.M_nominal)
       - 1))))/(1 - 2*cHP_PowerUnit.inductionMachine.s_nominal*((cHP_PowerUnit.inductionMachine.M_til
      /cHP_PowerUnit.inductionMachine.M_nominal) - 1)))
    "Tilting slip of electric machine" annotation (Dialog(tab="Calibration parameters",
        group="Fast calibration - Electric power and fuel usage"));
  parameter Real calFac=0.94
    "Calibration factor for electric power output (default=1)"
    annotation (Dialog(tab="Calibration parameters",
    group="Fast calibration - Electric power and fuel usage"));
  parameter Modelica.SIunits.ThermalConductance GEngToCoo=33
    "Thermal conductance of engine housing from the cylinder wall to the water cooling channels"
    annotation (Dialog(tab="Calibration parameters",group=
          "Fast calibration - Thermal power output"));
  parameter Modelica.SIunits.ThermalConductance GCooExhHex=400
    "Thermal conductance of the coolant heat exchanger at nominal flow"
    annotation (Dialog(tab="Calibration parameters",group=
          "Fast calibration - Thermal power output"));
  parameter Modelica.SIunits.HeatCapacity CExhHex=50000
    "Heat capacity of exhaust heat exchanger(default= 4000 J/K)" annotation (
     Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
protected
  parameter Modelica.SIunits.Mass mEng=CHPEngineModel.mEng + Cal_mEng
    "Total engine mass for heat capacity calculation"
    annotation (Dialog(tab="Calibration parameters",group="Advanced calibration parameters"));
public
  parameter Modelica.SIunits.Mass Cal_mEng=0
    "Added engine mass for calibration purposes of the system´s thermal inertia"
    annotation (Dialog(tab="Calibration parameters",group="Advanced calibration parameters"));
  parameter Modelica.SIunits.Area A_surExhHea=100
    "Surface for exhaust heat transfer"
    annotation (Dialog(tab="Calibration parameters",group="Advanced calibration parameters"));
  parameter Modelica.SIunits.MassFlowRate m_flow_Coo=0.4
    "Nominal mass flow rate of coolant inside the engine cooling circle" annotation (
     Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
  parameter Modelica.SIunits.Thickness dInn=0.01
    "Typical value for the thickness of the cylinder wall (between combustion chamber and cooling circle)"
    annotation (Dialog(tab="Calibration parameters",group="Fast calibration - Thermal power output"));
  parameter Modelica.SIunits.ThermalConductance GEngToAmb=2
    "Thermal conductance from engine housing to the surrounding air"
    annotation (Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
  parameter Modelica.SIunits.ThermalConductance GAmb=10
    "Constant heat transfer coefficient of engine housing to ambient" annotation (
     Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
  parameter Real modTab[:,2]=[0.0,0.8; 7200,0.8; 7200,0.93; 10800,0.93; 10800,0.62;
      14400,0.62; 14400,0.8; 18000,0.8; 18000,0.0]
    "Table for unit modulation (time = first column; modulation factors = second column)"
    annotation (Dialog(tab="Calibration parameters", group="Fast calibration - Electric power and fuel usage"));
  parameter Modelica.SIunits.TemperatureDifference dT_nominal=25 "Nominal heat exchanger temperature difference between cooling and heating circuit"
    annotation (Dialog(tab="Calibration parameters", group=
          "Advanced calibration parameters"));
  parameter Modelica.Blocks.Interfaces.RealInput GCooHex=CHPEngineModel.Q_MaxHea
      /dT_nominal*2
    "Signal representing the convective thermal conductance of the coolant heat exchanger in [W/K]"
    annotation (Dialog(tab="Calibration parameters", group="Advanced calibration parameters"));
  parameter Boolean ConTec=true
    "Is condensing technology used and should latent heat be considered?"
    annotation (Dialog(tab="Advanced", group="Latent heat use"));
  parameter Boolean useGenHea=true
    "Is the thermal loss energy of the elctric machine used?"
    annotation (Dialog(tab="Advanced", group="Generator heat use"));
  parameter Boolean allowFlowReversalExhaust=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal for exhaust medium"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Boolean allowFlowReversalCoolant=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal for coolant medium"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mExh_flow_small=0.001
    "Small exhaust mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mCool_flow_small=0.005
    "Small coolant mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));

  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.ModularCHP_PowerUnit_EASY_Experimental
    cHP_PowerUnit(
    redeclare package Medium_Fuel = Medium_Fuel,
    CHPEngineModel=CHPEngineModel,
    EngMat=EngMat,
    T_amb=T_amb,
    p_amb=p_amb,
    m_flow=m_flow_Coo,
    GEngToCoo=GEngToCoo,
    ConTec=ConTec,
    useGenHea=useGenHea,
    allowFlowReversalExhaust=allowFlowReversalExhaust,
    allowFlowReversalCoolant=allowFlowReversalCoolant,
    mExh_flow_small=mExh_flow_small,
    mCool_flow_small=mCool_flow_small,
    A_surExhHea=A_surExhHea,
    mEng=mEng,
    redeclare package Medium_Coolant = Medium_Coolant,
    GCooExhHex=GCooExhHex,
    CExhHex=CExhHex,
    dInn=dInn,
    GEngToAmb=GEngToAmb,
    GAmb=GAmb,
    calFac=calFac,
    s_til=s_til)
    annotation (Placement(transformation(extent={{-24,0},{24,48}})));

  AixLib.Fluid.HeatExchangers.DynamicHX             coolantHex(
    allowFlowReversal1=allowFlowReversalCoolant,
    allowFlowReversal2=allowFlowReversalCoolant,
    m2_flow_nominal=CHPEngineModel.m_floCooNominal,
    m1_flow_small=mCool_flow_small,
    m2_flow_small=mCool_flow_small,
    redeclare package Medium1 = Medium_Coolant,
    m1_flow_nominal=m_flow_Coo,
    redeclare package Medium2 = Medium_HeatingCircuit,
    dp1_nominal(displayUnit="kPa") = 0,
    dp2_nominal(displayUnit="kPa") = 0,
    nNodes=1,
    Q_nom=CHPEngineModel.Q_MaxHea,
    dT_nom=dT_nominal,
    Gc1=GCooHex,
    Gc2=coolantHex.Gc1)
             annotation (Placement(transformation(extent={{20,-72},{-20,-32}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort temRetFlo(
    m_flow_small=mCool_flow_small,
    m_flow_nominal=CHPEngineModel.m_floCooNominal,
    redeclare package Medium = Medium_HeatingCircuit)
    annotation (Placement(transformation(extent={{-58,-72},{-42,-56}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort temSupFlo(
    m_flow_small=mCool_flow_small,
    m_flow_nominal=CHPEngineModel.m_floCooNominal,
    redeclare package Medium = Medium_HeatingCircuit)
    annotation (Placement(transformation(extent={{42,-72},{58,-56}})));

  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.OnOff_ControllerEasy
    ControllerCHP(CHPEngineModel=CHPEngineModel, startTimeChp=3600,
    modTab=modTab)                                                  annotation (
     Placement(transformation(rotation=0, extent={{-76,64},{-44,96}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_retHea(redeclare package Medium =
        Medium_Coolant)
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_supHea(redeclare package Medium =
        Medium_Coolant)
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));

  Modelica.Fluid.Sources.FixedBoundary fixedPressureLevel(
    nPorts=1,
    redeclare package Medium = Medium_Coolant,
    T(displayUnit="K"),
    p=300000)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-74,-20})));
equation
  connect(coolantHex.port_a2, temRetFlo.port_b)
    annotation (Line(points={{-20,-64},{-42,-64}}, color={0,127,255}));
  connect(coolantHex.port_b2, temSupFlo.port_a)
    annotation (Line(points={{20,-64},{42,-64}}, color={0,127,255}));
  connect(coolantHex.port_b1,cHP_PowerUnit.port_retCoo)  annotation (Line(
        points={{-20,-40},{-60,-40},{-60,10.08},{-19.2,10.08}}, color={0,127,
          255}));
  connect(cHP_PowerUnit.port_supCoo, coolantHex.port_a1) annotation (Line(
        points={{19.2,10.08},{60,10.08},{60,-40},{20,-40}}, color={0,127,255}));
  connect(temSupFlo.port_b, port_supHea) annotation (Line(points={{58,-64},{90,
          -64},{90,0},{100,0}}, color={0,127,255}));
  connect(port_retHea, temRetFlo.port_a) annotation (Line(points={{-100,0},{-90,
          0},{-90,-64},{-58,-64}}, color={0,127,255}));
  connect(fixedPressureLevel.ports[1], cHP_PowerUnit.port_retCoo) annotation (
      Line(points={{-64,-20},{-60,-20},{-60,10.08},{-19.2,10.08}}, color={0,127,
          255}));
  connect(ControllerCHP.modCHPConBus, cHP_PowerUnit.sigBusCHP) annotation (Line(
      points={{-44,80},{-0.24,80},{-0.24,46.32}},
      color={255,204,51},
      thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Text(
          extent={{-50,58},{50,18}},
          lineColor={255,255,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={175,175,175},
          textString="CHP",
          textStyle={TextStyle.Bold}),
                              Rectangle(
          extent={{-60,80},{60,-80}},
          lineColor={0,0,0},
          fillPattern=FillPattern.VerticalCylinder,
          fillColor={170,170,255}),                                       Text(
          extent={{-50,68},{50,28}},
          lineColor={255,255,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={175,175,175},
          textStyle={TextStyle.Bold},
          textString="Modular
CHP"),  Rectangle(
          extent={{-12,6},{12,-36}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-10,-16},{-10,-36},{-8,-30},{8,-30},{10,-36},{10,-16},{-10,-16}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-2,-26},{4,-32}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-18,-54},{-8,-64}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-2,-30},{-14,-54},{-10,-56},{0,-32},{-2,-30}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-4.5,-15.5},{-8,-10},{0,4},{6,-4},{10,-4},{8,-8},{8,-12},{5.5,
              -15.5},{-4.5,-15.5}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={255,127,0}),
        Polygon(
          points={{-4.5,-13.5},{0,-4},{6,-10},{2,-14},{-4.5,-13.5}},
          lineColor={255,255,170},
          fillColor={255,255,170},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-90,0},{-60,0}},
          color={0,127,255},
          thickness=1),
        Line(
          points={{60,0},{90,0}},
          color={0,127,255},
          thickness=1)}),                                        Diagram(
        coordinateSystem(preserveAspectRatio=false)),
         __Dymola_Commands(file="Modelica://AixLib/Resources/Scripts/Dymola/Fluid/CHP/Examples/CHP_OverviewScript.mos" "QuickOverviewSimulateAndPlot"),
    Documentation(info="<html>
<p>This model of a gas engine CHP plant is aggregated from runnable and closed submodels. The model is able to map different gas engine CHPs of small and medium power classes (&lt; 200 kWel). It allows an investigation of the thermal and electrical dynamics of the individual components and the entire plant. In addition, a CO2 balance can be calculated for the comparison of different control strategies. </p>
<p>The modular CHP model is aggregated from closed submodels that can be run on their own. These are based on physical calculation approaches and offer mechanical, material and thermal interfaces. The thermal interconnection of the exhaust gas heat exchanger and combustion engine in the internal primary circuit is freely selectable. Detailed explanations of how the submodels work are provided in their documentation. Parameterization and control are realized on the highest model level using bus ports to transmit measured and calculated signals throughout the different hierarchical model levels.</p>
<h4>Calibration:</h4>
<p>If the calibration of the model is not to be performed for all listed calibration quantities, a quick adaptation of the essential model quantities for the use of are carried out. Setting the speed of the generator and internal combustion engine for the nominal power point using the calibration variables tilting slip, electrical calibration factor and modulation factor results in a high correspondence for electrical power and fuel input for each power stage of the CHP. The thermal output can then be checked by checking the flue gas temperature when the system exits. The examination of the data sheets of some cogeneration units provides general comparative values for the flue gas temperature in a range around 50 &deg;C with and around 110 &deg;C without condensing utilisation at rated output. The flue gas temperature can mainly be adjusted using the heat transitions G_CoolChannel and G_CooExhHex. Finally, the parameters of the heat exchanger can be adapted to the heating circuit.</p>
<h4>Limitations:</h4>
<p>Supercharged internal combustion engines and diesel engines cannot be completely mapped.</p>
</html>"));
end ModularCHP_DynamicHX_EASY_EXPERIMENTAL;
