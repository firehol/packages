# FireHOL packages

This repository is intended to provide
[pre-built packages](https://github.com/firehol/packages/releases/latest)
for distributions that do not have them as standard.

Current status:

Package                   | Architecture     |  Installs  |  Runs  |  Works
------------------------- | ---------------- | ---------- | ------ | -------
FireHOL OpenWRT 22.03 ipk | all              |     ?      |   ?    |    ?
FireHOL CentOS/RHEL 8 rpm | all (noarch)     |     ?      |   ?    |    ?
FireHOL CentOS/RHEL 9 rpm | all (noarch)     |     ?      |   ?    |    ?
iprange OpenWRT 22.03 ipk | bcm47xx          |     ?      |   ?    |    ?
iprange OpenWRT 22.03 ipk | ipq806x          |     ?      |   ?    |    ?
iprange CentOS/RHEL 8 rpm | amd64            |     ?      |   ?    |    ?
iprange CentOS/RHEL 9 rpm | amd64            |     ?      |   ?    |    ?

Basically: I run the builds but don't check them personally. I update this
table when people report success/failure.

It is all something of a best-effort basis, so pull requests to add new
packaging formats, architectures, or updated versions are always welcome.

# Old packages

CentOS7/RHEL 7 package build no longer works. Last built RPMs are
[here](https://github.com/firehol/packages/releases/tag/2021-01-01-1948).

CentOS6/RHEL 6 package build no longer works. Last built RPMs are
[here](https://github.com/firehol/packages/releases/tag/2020-03-19-1724).

Last builds for OpenWRT 19.07 (and last ar71xx build) are
[here](https://github.com/firehol/packages/releases/tag/2021-01-01-1948).

Last builds for OpenWRT 18.06 are
[here](https://github.com/firehol/packages/releases/tag/2020-02-18-0552).

# Releases

Everything gets built by Github Actions; tags are created after a package
update or new output is added which automatically puts all the
binaries into github releases:

~~~~
git push
# wait...
git tag YYYY-MM-DD-hhmm
git push --tags
~~~~

# Building outside Github

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

Github Actions runs each `build-*.sh` script in order and provided
everything builds OK, it builds checksums in `outputs/checksums`.

## Dependencies

* The OpenWRT builds need ccache and basic build tools (make etc.) installed
* The CentOS/Redhat builds need docker (docker.io on Ubuntu) installed
  and to be able to run sudo
