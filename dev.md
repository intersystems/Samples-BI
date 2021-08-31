# Developer Notes

This file complements the [main README](README.md) with additional background on how this sample can be set up and what automation was added.

## Files used in this repository

Sample code
* `src/cls/`: This folder contains the main ObjectScript code for this sample and its contents is described in the [main README](README.md)
* `src/gbl/ZipCodeData.xml` contains a global export with static data used in the sample

Setup options
* Manual setup:
  * `buildsample/Build.SampleBI.xml` has the ObjectScript code to manually configure and populate the sample, as explained in the [main README](README.md)
* ZPM setup:
  * `module.xml` is the main descriptor file for setting up the sample through [ZPM](https://github.com/intersystems-community/zpm), as an alternative to the manual setup procedure
* Docker setup:
  * `Dockerfile` has the build recipe for building an entire Docker image out of this sample repository
  * `Installer.cls` is an [installation manifest](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCI_MANIFEST) loaded during the Docker build step as part of the `iris.script` it invokes. That makes this yet another alternative for setting up the sample, although one that builds a full image rather than add to an existing IRIS instance. 
  * `.dockerignore` is a standard Docker configuration file to leave some repository contents out of the Docker build scope
  * `docker-compose.xml` adds convenience by scripting how to launch a container based on that image.

Miscellaneous
* `.vscode` is a configuration file for [Visual Studio Code](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=PAGE_vscode), the recommended editor for ObjectScript code on InterSystems IRIS 
* `.gitattributes` and `.gitignore` are configuration files for Git source control and otherwise don't impact the sample
* `.github/workflows/` has a few scripts for automated CI/CD workflows, leveraging [GitHub Actions](https://github.com/features/actions)

## Useful commands

### Build container with no cache
```
docker-compose build --no-cache --progress=plain
```

### Open terminal to docker in a NAMESPACE
```
docker-compose exec iris iris session iris -U IRISAPP
```

### Clear docker fs
```
docker system prune -f
```

### Open SQL shell
```ObjectScript
d $System.SQL.Shell()
```




