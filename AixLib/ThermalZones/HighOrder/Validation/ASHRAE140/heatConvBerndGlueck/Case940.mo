within AixLib.ThermalZones.HighOrder.Validation.ASHRAE140.heatConvBerndGlueck;
model Case940
  extends heatConvBerndGlueck.Case640(
                  Room(wallTypes(OW=AixLib.DataBase.Walls.ASHRAE140.OW_Case900(),
          groundPlate_upp_half=AixLib.DataBase.Walls.ASHRAE140.FL_Case900())));
  annotation (Documentation(info="<html>
<p>As described in ASHRAE Standard 140.</p>
<p>Difference to case 900:</p>
<ul>
<li>From 2300 hours to 0700 hours, heat = ON if temperature &lt; 10 degC</li>
<li>From 0700 hours to 2300 hours, heat = ON if temperature &lt; 20 degC</li>
</ul>
</html>", revisions="<html>
 <ul>
 <li><i>March 9, 2015</i> by Ana Constantin:<br/>Implemented</li>
 </ul>
 </html>"));
end Case940;