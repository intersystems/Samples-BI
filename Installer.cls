Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="SourceDir" Value="#{$system.Process.CurrentDirectory()}src"/>
  <Default Name="Namespace" Value="IRISAPP"/>
  <Default Name="app" Value="irisapp" />
  <Default Name="restapp" Value="/rest-test" />

  <Namespace Name="${Namespace}" Code="${Namespace}" Data="${Namespace}" Create="yes" Ensemble="no">

    <Configuration>
      <Database Name="${Namespace}" Dir="/opt/${app}/data" Create="yes" Resource="%DB_${Namespace}"/>

      <Import File="${SourceDir}" Flags="ck" Recurse="1"/>
    </Configuration>
    <CSPApplication Url="/csp/${app}" 
      Directory="${cspdir}${app}" 
      ServeFiles="1"
      Recurse="1" 
      Grant="%DB_${Namespace},%SQL"
      AuthenticationMethods="32"
       
    />
    <CSPApplication Url="${restapp}"
      Recurse="1"
      Directory="${cspdir}${restapp}" 
      Grant="%DB_${Namespace},%SQL"
      AuthenticationMethods="96"
      />

  </Namespace>
    <Invoke Class="App.Installer" Method="SetDispatchClass">
    <Arg Value="${restapp}"/>
    <Arg Value="community.objectscript.RESTExample"/>
  </Invoke>


</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod SetDispatchClass(pApp As %String, pClass As %String) As %Status
{
  New $Namespace
  Set $Namespace = "%SYS"
  Set tSC = ##class(Security.Applications).Get(pApp, .webProperties)
  If $$$ISERR(tSC) {
    Quit tSC
  }
  
  Set webProperties("DispatchClass") = pClass
  Set tSC = ##class(Security.Applications).Modify(pApp, .webProperties)
  Quit tSC
}

}
