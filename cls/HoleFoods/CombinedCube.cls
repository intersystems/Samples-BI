/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Sample of a DeepSee compound cube.
/// This combine the HoleFoods Sales data with the Holefoods budget data into one model.
Class HoleFoods.CombinedCube Extends %DeepSee.SubjectArea [ DependsOn = (HoleFoods.Cube, HoleFoods.BudgetCube), ProcedureBlock ]
{

Parameter DOMAIN;

/// SubjectArea definition from Architect.
XData SubjectArea [ XMLNamespace = "http://www.intersystems.com/deepsee/subjectarea" ]
{
<subjectArea xmlns="http://www.intersystems.com/deepsee/subjectarea" name="HoleFoodsCombined" caption="HoleFoods Combined" disabled="false" baseCube="HoleFoods,HoleFoodsBudget">

<calculatedMember dimension="Measures" name="Variance" valueExpression="ISNULL([Measures].[Amount Sold],0)-ISNULL([Measures].[Target],0)" formatString="#,##.##;(#,##.##)"/>

</subjectArea>
}

}

