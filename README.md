# Schéma, an Integrated Creative Environment
Schéma provides an intuitive visual programming interface and runtime.

The system is focused on multimedia installations for use in music performances, theater shows, film lighting or interactive art exhibits but is general-purpose and can be expanded.

## Download pre-compiled releases
https://domj.itch.io/schema

## Learn how to drive it
https://docs.scenic.tools/

## Explore features and use-cases
https://schema.scenic.tools/

## Join the community and get help
https://discord.gg/Q27rcfd


## Running from source and vvvv gamma integration

Schema is developed using the vvvv gamma .NET visual programming environment, stable release.

You can use the source to run or modify Schema and to integrate with other vvvv gamma projects. For pre-compiled releases, see above.

Last tested version: vvvv gamma 5.2
Download at http://visualprogramming.net/

It will likely work with higher versions as well, however there may be undocumented bugs, superficial document changes after saving and more.

### First setup and run

1. Clone this repository to run Schema from source.

```powershell
git clone https://github.com/domjancik/scnq-schema.git
```

2. Install nuget dependencies

```powershell
.\Main\installDependencies.ps1
```

This should avoid any red error nodes after opening. If you still see any after the next step, double-check that all required Dependencies are installed.

3. Open in vvvv gamma

Full application files are within the `Main/gamma` folder

There are a few patches, choose depending on your need:

- `Schema_Minimal.vl` Barebones running example of the Schema system with UI. No extra Blocks outside of Core or Plugins (specific outputs, etc.)
- `Schema_Studio.vl` The full version including all stable features and UI. This is the released Schema Studio executable.
- `Schema_Lite.vl` No-UI version intended for deployments, also targeting Linux. No Windows specific (graphical and some outputs) Plugins included.

### Integrating with vvvv gamma projects

Explore available methods on the Schema State object.

Block creation and other guides upcoming.