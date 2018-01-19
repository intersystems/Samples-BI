/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Example of a DeepSee Subject Area.
/// This limits the data from the HOLEFOODS cube to data from ASIA only.
Class HoleFoods.SubjectAreaAsia Extends %DeepSee.SubjectArea [ DependsOn = HoleFoods.Cube, ProcedureBlock ]
{

Parameter DOMAIN;

/// SubjectArea definition from Architect.
XData SubjectArea [ XMLNamespace = "http://www.intersystems.com/deepsee/subjectarea" ]
{
<subjectArea xmlns="http://www.intersystems.com/deepsee/subjectarea" name="HoleFoods Asia" caption="HoleFoods Asia" disabled="false" baseCube="HoleFoods" filterSpec="[OUTLET].[H1].&amp;[ASIA]">
</subjectArea>
}

}

