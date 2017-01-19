# FireHOL packages

This repository is intended to provide pre-built packages for distributions
that do not have them as standard.

Current status:

Package                   | Architecture     |  Installs  |  Runs  |  Works
------------------------- | ---------------- | ---------- | ------ | -------
FireHOL OpenWRT 15.05 ipk | all              |     Y      |   Y    |    Y
FireHOL CentOS/RHEL 6 rpm | all (noarch)     |     Y      |   ?    |    ?
FireHOL CentOS/RHEL 7 rpm | all (noarch)     |     Y      |   ?    |    ?
iprange OpenWRT 15.05 ipk | ar71xx           |     Y      |   Y    |    ?
iprange OpenWRT 15.05 ipk | brcm47xx         |     ?      |   ?    |    ?
iprange CentOS/RHEL 6 rpm | amd64            |     Y      |   ?    |    ?
iprange CentOS/RHEL 7 rpm | amd64            |     Y      |   ?    |    ?

Basically: I use FireHOL and FireQOS on an OpenWRT ar71xx box. I will update
the table when people report success/failure.

It is all something of a best-effort basis, so pull requests to add new
packaging formats, architectures, or updated versions are always welcome.

# Releases

Everything gets built by Travis-CI; tags are created after a package
update or new output is added which automatically puts all the
binaries into github releases.

# Building outside Travis

Clone the repository and run the common setup script:

~~~~
git clone https://github.com/firehol/packages.git firehol-packages
cd firehol-packages
./setup.sh
~~~~

Then run any individual (`build-PLATFORM.sh`) scripts you are interested
in e.g.:

~~~~
./build-openwrt.sh
~~~~

Provided everything works, the outputs all go to `outputs/packages`.
If something goes wrong you most likely need to install a
[dependency](#dependencies) on your build host.

Travis runs each `build-*.sh` script in order and provided everything
builds OK, it builds checksums in `outputs/checksums`.

## Dependencies

* The OpenWRT builds need ccache and basic build tools (make etc.) installed
* The CentOS/Redhhat builds need docker (docker.io on Ubuntu) installed
  and to be able to run sudo
