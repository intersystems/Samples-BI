/// This is from https://github.com/intersystems/Samples-BI.
/// This class builds the downloaded sample files from https://github.com/intersystems/Samples-BI.
/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class Build.BISample Extends %RegisteredObject
{

/// This method prompts the user for the name of the directory that contains the downloaded files 
/// and then builds the sample.
ClassMethod Build()
{
	write !, "This is the setup method for the Samples-BI sample, which is meant for use with"
    write !, "the InterSystems IRIS Business Intelligence capabilities. To use this sample,"
    write !, "you must have an InterSystems IRIS license that includes analytics capabilities."

    write !!, "To continue, please specify the full path of the directory that contains this "
    write !, "sample. (This is the directory that contains the README.md and LICENSE files.)",!
    read "Your input: ",stagingroot
    if ($ZSTRIP(stagingroot,"<>W")="") {
        write !, "Not a valid directory. Quitting..."
        quit
    }
    set exists=##class(%File).DirectoryExists(stagingroot)
    if 'exists {
        write !, "Directory not found. Quitting..."
        quit
    }
    
    set OK=..run(stagingroot,1)
    
    if OK {
        write !!, "IMPORTANT: If there were build errors while setting up this sample, your"
        write !, "license might not include analytics capabilities. "
        write !, "(This setup code does not check your license.)"
        write !!, "Before using this sample, see the README.md file for information on setting up"
        write !, "a web application in this namespace and enabling that web application to use"
        write !, "analytics capabilities."
        write !!, "Then open the Management Portal and access the Analytics menu in this namespace."
        write !, "See the README.md file for details on this sample and links to documentation."
    } else {
        write !!, "Setup was unsuccessful. Make sure that the directory you specified"
        write !, "contains the sample files for *this* sample."
    }
}

/// This method enables you to build the sample with a minimum of output to the Terminal.
/// <var>stagingroot</var> is the name of the directory that contains the downloaded files. 
/// <var>interactive</var> controls whether this method displays output.
/// <methodname>Build</methodname> calls this method with interactive=1.
ClassMethod run(stagingroot As %String = "", interactive As %Boolean = 0)
{
    //repeat this test here in case we go directly to this method
    if $ZSTRIP(stagingroot,"<>W")="" {
        if interactive {
            write !, "Not a valid directory... Quitting."
        }
        return 0
    }

    // Load and compile classes ***************************
    set dir=stagingroot_"/src/cls/" ;works on both Windows and Unix
    if '##class(%File).DirectoryExists(dir) {
        if interactive {
            write !!, "Looking for "_dir
            write !, "but it does not exist... Quitting."
        }
        return 0
    }
    if interactive {
        write !!, "Loading and compiling classes..."
    }
    do $system.OBJ.LoadDir(dir,"ck",,1)

    // Execute the setup code in the loaded classes *********************
    if '##class(%Dictionary.CompiledClass).%ExistsId("BI.Populate") {
        if interactive {
            write !!, "Looking for the class BI.Populate but it does not exist... Quitting."
        }
        return 0
    }
    
    // After classes have been loaded, load data
    set dir=stagingroot_"/src/gbl/" ;works on both Windows and Unix
    if '##class(%File).DirectoryExists(dir) {
        if interactive {
            write !!, "Looking for "_dir
            write !, "but it does not exist... Quitting."
        }
        return 0
    }
    if interactive {
        write !!, "Loading data..."
    }
    do $system.OBJ.LoadDir(dir,"ck",,1)
    
    if interactive {
        write !, "Running the BI.Populate.Setup() method..."
    }
    do ##class(BI.Populate).Setup()

    if '##class(%Dictionary.CompiledClass).%ExistsId("HoleFoods.Utils") {
        if interactive {
            write !!, "Looking for the class HoleFoods.Utils but it does not exist... Quitting."
        }
        return 0
    }
    if interactive {
        write !, "Running the HoleFoods.Utils.Setup() method..."
    }
    do ##class(HoleFoods.Utils).Setup()
    return 1
}

}
