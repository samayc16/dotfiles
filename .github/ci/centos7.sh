#!/bin/bash
# The CentOS 7 leg (glibc 2.17, git 1.8.3), run as root inside a centos:7 container by the
# workflow's centos7 job, with the checkout and the pins artifact mounted read-only at /src.
# GitHub's own actions need a newer glibc than CentOS 7's, so the job can't use `container:`.
# Like the other no-root legs: a minimal base (git, curl, a compiler; no Python, no zsh, no
# sudo), then the release tarball installed by an ordinary user, then .github/ci/verify.sh.
set -euo pipefail

# CentOS 7 is end of life: its packages moved to vault.centos.org (yum still checks their GPG
# signatures). Pin the release, since the vault has no `7` alias.
# shellcheck disable=SC2016 # $releasever is the repo file's own text, not a shell variable
sed -i -e 's/^mirrorlist=/#mirrorlist=/' \
  -e 's|^#\{0,1\}baseurl=http://mirror.centos.org/centos/$releasever|baseurl=https://vault.centos.org/7.9.2009|' \
  /etc/yum.repos.d/CentOS-*.repo
yum --disablerepo='*' --enablerepo=base,updates,extras install -y -q git curl ca-certificates tar xz gzip unzip make gcc gcc-c++ util-linux findutils file which >/dev/null
echo "base: $(git --version), $(ldd --version | head -n1)"

useradd -m -s /bin/bash tester
install -m 755 /src/bin/dotfiles /tmp/dotfiles-cli
install -m 644 /src/ci-artifacts/dotfiles.tar.gz /tmp/dotfiles.tar.gz
install -m 755 /src/.github/ci/verify.sh /tmp/verify.sh

# CentOS 7's runuser (util-linux 2.23) has no -u, so su; the arguments pass through quoted
as_tester() { su -s /bin/bash tester -c "$(printf '%q ' "$@")"; }

as_tester env HOME=/home/tester GITHUB_TOKEN="${GITHUB_TOKEN:-}" NO_COLOR=1 \
  bash /tmp/dotfiles-cli install --from /tmp/dotfiles.tar.gz --no-sudo --profile dev --with hdl,music --no-log
as_tester env HOME=/home/tester RELEASE=1 NVIM=1 SIM=1 \
  PINS=/home/tester/.local/share/dotfiles/current/pins.txt sh /tmp/verify.sh
