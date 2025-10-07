# Plastimatch_docker_snap

## Description

These scripts provide an automated way to build a Snap package of **Plastimatch** using Docker and Snapcraft.  
The package can then be installed on any Linux system with Snap support.

---

### Requirements

- [Docker](https://docs.docker.com/engine/) – needed to build the Snap inside a container
- [Snapd](https://snapcraft.io/docs/installing-snapd) – needed just to test the generated Snap package

---

### Build the Snap Package

Run the following command to build the container and generate the snap package:

```bash
docker run -it --rm --entrypoint /bin/bash --name build_plastimatch -v $PWD:/build -w /build ghcr.io/canonical/snapcraft:8_core24 /build/build_snap.sh
```

After completion, you will find the `plastimatch_*.snap` file in the build folder.

---

### Install the Snap Package

Once the build is done, the generated package can be installed by:

```bash
sudo snap install plastimatch_*.snap --dangerous
```

**Note:**  
The `--dangerous` flag is required because the package was built locally and is not signed by the official Snap store.


