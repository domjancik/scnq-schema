# Schema vvvv beta patches

These are archived vvvv beta patches from initial Schema development before the existence of vvvv gamma (standalone VL)/when vvvv gamma was very limited.

They may still contain some interesting and yet (as of writing) unimplemented features such as:
- GPU based pixel calculation for distances (used in Chapeau Rouge)
- 3D extra visualization used as backdrop in schematic view (using CraftLie)
- OctoWS2811 control
- Stepper motor control via OSC (used in Ghost in the Machine, partially implemented in Schema Studio with OSC Output plugin)
- Audio analysis
- OpenVR integration for controller interactions (used in Spatial Light Painting)
- Remote state (used in a Schema Workshop)

See project gallery for the mentioned projects: https://schema.scenic.tools/gallery/

## Using patches

To use a patch, copy it over to the `/Main` directory.

You may also need to copy over the `plugins` directory, which should be necessary only for OctoWS2811 patches.