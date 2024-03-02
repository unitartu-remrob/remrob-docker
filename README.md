

# Running performance tests

This branch uses modified versions of Gazebo-classic v11.14.0 that help extract FPS measures from either a Gazebo simulation or an Rviz simulation. The extracted data is saved in `$HOME/.ros`.

If only running the test client (no server setup), then no need to install submodules. The scripts under `metrics` is all that's necessary.

Build as regular:

```bash
docker build -t robotont:performance-tests . # Image name is arbitrary, but remember to change in compose templates in remrob-server
```

To run the tests:

1) Disable workspace mapping in remrob-server when using a freshly-built image that has new packages (e.g., source-built Rviz & Gazebo), otherwise the saved workspace overrides them.
2) In `remrob-server` simulation compose template (`server/compose/templates/local.j2`) make sure the image name is correct (e.g. `robotont:performance-tests`), and that the FPS volume file mounts are present. E.g. map to a)`$HOME/.ros/FPS_out.txt` for RViz and b)`$HOME/.ros/GAZEBO_FPS_out.txt` for Gazebo image.

!NB

- Remember to disable workspace mapping in remrob-server when using a freshly-built image that has new packages, otherwise the saved workspace overrides them. Another option is to move the old workspace out of the directory it's being mapped to. When performance measurements are done, the workspace can be moved back in.