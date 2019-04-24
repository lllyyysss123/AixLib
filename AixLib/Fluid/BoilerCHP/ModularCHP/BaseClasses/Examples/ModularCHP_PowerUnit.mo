﻿within AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.Examples;
model ModularCHP_PowerUnit
  "Example of the modular CHP power unit model inside a heating circuit"
  extends Modelica.Icons.Example;
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
    "Default ambient pressure" annotation (Dialog(group=
          "Ambient Parameters"));
  Modelica.SIunits.Temperature T_Ret=senTRetHea.T "Coolant return temperature";
  Modelica.SIunits.Temperature T_Sup=senTSupHea.T "Coolant supply temperature";
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
    annotation (Dialog(tab="Calibration parameters",group="Fast calibration - Thermal power output"));
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
    annotation (Dialog(tab="Calibration parameters",group="Advanced calibration parameters"));
  parameter Modelica.SIunits.ThermalConductance GAmb=10
    "Constant heat transfer coefficient of engine housing to ambient" annotation (
     Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
  parameter Real modTab[:,2]=[0.0,0.8; 7200,0.8; 7200,0.93; 10800,0.93; 10800,0.62;
      14400,0.62; 14400,0.8; 18000,0.8; 18000,0.0]
    "Table for unit modulation (time = first column; modulation factors = second column)"
    annotation (Dialog(tab="Calibration parameters", group="Fast calibration - Electric power and fuel usage"));
  parameter Modelica.SIunits.Temperature T_HeaRet=303.15
    "Constant heating circuit return temperature"
    annotation (Dialog(tab="Engine Cooling Circle"));
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
  Modelica.SIunits.MassFlowRate m_flow_HeaCir=if not VolCon then CHPEngineModel.m_floCooNominal
       else V_flow_HeaCir*senDen.d
    "Nominal mass flow rate inside the heating circuit"
    annotation (Dialog(tab="Engine Cooling Circle"));
  Modelica.SIunits.VolumeFlowRate V_flow_HeaCir=0.3/3600
    "Nominal volume flow rate inside the heating circuit" annotation (Dialog(tab=
          "Engine Cooling Circle"));
  parameter Boolean VolCon=true  "Is volume flow rate control used?"
    annotation (Dialog(tab="Engine Cooling Circle"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mExh_flow_small=0.001
    "Small exhaust mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mCool_flow_small=0.005
    "Small coolant mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));

  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.ModularCHP_PowerUnit_EASY
    cHP_PowerUnit(
    redeclare package Medium_Fuel = Medium_Fuel,
    CHPEngineModel=CHPEngineModel,
    EngMat=EngMat,
    T_amb=T_amb,
    p_amb=p_amb,
    m_flow=m_flow_Coo,
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
    GAmb=GAmb,
    calFac=calFac,
    GEngToCoo=GEngToCoo,
    GEngToAmb=GEngToAmb)
    annotation (Placement(transformation(extent={{-24,0},{24,48}})));

  AixLib.Fluid.HeatExchangers.ConstantEffectiveness coolantHex(
    allowFlowReversal1=allowFlowReversalCoolant,
    allowFlowReversal2=allowFlowReversalCoolant,
    m2_flow_nominal=CHPEngineModel.m_floCooNominal,
    m1_flow_small=mCool_flow_small,
    m2_flow_small=mCool_flow_small,
    redeclare package Medium1 = Medium_Coolant,
    m1_flow_nominal=m_flow_Coo,
    redeclare package Medium2 = Medium_HeatingCircuit,
    dp1_nominal(displayUnit="kPa") = 10000,
    dp2_nominal(displayUnit="kPa") = 10000,
    eps=0.9)
    annotation (Placement(transformation(extent={{20,-72},{-20,-32}})));
  Modelica.Fluid.Sources.MassFlowSource_T heatingReturnFlow(
    use_T_in=true,
    redeclare package Medium = Medium_HeatingCircuit,
    nPorts=1,
    use_m_flow_in=true)
    annotation (Placement(transformation(extent={{-108,-74},{-88,-54}})));
  Modelica.Fluid.Sources.FixedBoundary heatingSupplyFlow(
                               nPorts=1, redeclare package Medium =
        Medium_HeatingCircuit)
    annotation (Placement(transformation(extent={{110,-74},{90,-54}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort senTRetHea(
    m_flow_small=mCool_flow_small,
    m_flow_nominal=CHPEngineModel.m_floCooNominal,
    redeclare package Medium = Medium_HeatingCircuit)
    annotation (Placement(transformation(extent={{-46,-72},{-30,-56}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort senTSupHea(
    m_flow_small=mCool_flow_small,
    m_flow_nominal=CHPEngineModel.m_floCooNominal,
    redeclare package Medium = Medium_HeatingCircuit)
    annotation (Placement(transformation(extent={{52,-72},{68,-56}})));

  Modelica.Blocks.Sources.RealExpression tempFlowHeating(y=T_HeaRet)
    annotation (Placement(transformation(extent={{-144,-76},{-124,-56}})));
  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.OnOff_ControllerEasy
    ControllerCHP(CHPEngineModel=CHPEngineModel, startTimeChp=3600,
    modTab=modTab)                                                  annotation (
     Placement(transformation(rotation=0, extent={{-76,64},{-44,96}})));
  AixLib.Fluid.Sensors.DensityTwoPort senDen(
    m_flow_small=mCool_flow_small,
    m_flow_nominal=CHPEngineModel.m_floCooNominal,
    redeclare package Medium = Medium_HeatingCircuit)
    annotation (Placement(transformation(extent={{-76,-72},{-60,-56}})));
  Modelica.Blocks.Sources.RealExpression massFlowHeating(y=m_flow_HeaCir)
    annotation (Placement(transformation(extent={{-144,-60},{-124,-40}})));

  Modelica.Fluid.Sources.FixedBoundary fixedPressureLevel(
    nPorts=1,
    redeclare package Medium = Medium_Coolant,
    T(displayUnit="K"),
    p=300000)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-74,-20})));
equation
  connect(coolantHex.port_a2, senTRetHea.port_b)
    annotation (Line(points={{-20,-64},{-30,-64}}, color={0,127,255}));
  connect(coolantHex.port_b2, senTSupHea.port_a)
    annotation (Line(points={{20,-64},{52,-64}}, color={0,127,255}));
  connect(senTSupHea.port_b, heatingSupplyFlow.ports[1])
    annotation (Line(points={{68,-64},{90,-64}}, color={0,127,255}));
  connect(heatingReturnFlow.T_in, tempFlowHeating.y)
    annotation (Line(points={{-110,-60},{-118,-60},{-118,-66},{-123,-66}},
                                                     color={0,0,127}));
  connect(ControllerCHP.modCHPConBus, cHP_PowerUnit.sigBusCHP) annotation (Line(
      points={{-44,80},{-0.24,80},{-0.24,46.32}},
      color={255,204,51},
      thickness=0.5));
  connect(heatingReturnFlow.ports[1], senDen.port_a)
    annotation (Line(points={{-88,-64},{-76,-64}}, color={0,127,255}));
  connect(senTRetHea.port_a, senDen.port_b)
    annotation (Line(points={{-46,-64},{-60,-64}}, color={0,127,255}));
  connect(massFlowHeating.y, heatingReturnFlow.m_flow_in) annotation (Line(
        points={{-123,-50},{-118,-50},{-118,-56},{-108,-56}}, color={0,0,127}));
  connect(coolantHex.port_b1,cHP_PowerUnit.port_retCoo)  annotation (Line(
        points={{-20,-40},{-60,-40},{-60,10.08},{-19.2,10.08}}, color={0,127,
          255}));
  connect(cHP_PowerUnit.port_supCoo, coolantHex.port_a1) annotation (Line(
        points={{19.2,10.08},{60,10.08},{60,-40},{20,-40}}, color={0,127,255}));
  connect(fixedPressureLevel.ports[1], cHP_PowerUnit.port_retCoo)
    annotation (Line(points={{-64,-20},{-60,-20},{-60,10.08},{-19.2,10.08}},
        color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), experiment(StopTime=18000, Interval=5), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
         __Dymola_Commands(file="Modelica://AixLib/Resources/Scripts/Dymola/Fluid/CHP/Examples/CHP_OverviewScript.mos" "QuickOverviewSimulateAndPlot"),
    Documentation(info="<html>
<p>An example of the use of modular CHP components combined as a power unit with interfaces to a controller and to the heating circuit.</p>
<p>It allows an impression of the versatile and complex application possibilities of the model by the changeability of many variables of individual components and the detailed investigation capability.</p>
<p>The return temperature as well as the volume flow in the heating circuit are considered constant.</p>
<p><br><br>Caution: </p>
<p>If the prime coolant cirlce of the power unit is using a gasoline medium instead of a liquid fluid, you may need to adjust (raise) the nominal mass flow and pressure drop of the cooling to heating heat exchanger to run the model, because of a background calculation for the nominal flow.</p>
</html>"));
end ModularCHP_PowerUnit;
