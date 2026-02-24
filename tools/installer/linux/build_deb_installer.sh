#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Version is required, e.g. 1.1.0}"
BUNDLE_DIR="${2:-build/linux/x64/release/bundle}"
OUTPUT_DIR="${3:-.}"
PACKAGE_NAME="LocalX-linux-x64-installer.deb"
PACKAGE_ID="localx"
PACKAGE_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "${PACKAGE_ROOT}"
}
trap cleanup EXIT

if [[ ! -d "${BUNDLE_DIR}" ]]; then
  echo "Bundle directory not found: ${BUNDLE_DIR}" >&2
  exit 1
fi

mkdir -p "${PACKAGE_ROOT}/DEBIAN"
mkdir -p "${PACKAGE_ROOT}/opt/localx"
mkdir -p "${PACKAGE_ROOT}/usr/share/applications"
mkdir -p "${PACKAGE_ROOT}/usr/share/icons/hicolor/256x256/apps"

cp -a "${BUNDLE_DIR}/." "${PACKAGE_ROOT}/opt/localx/"
install -m 0644 "assets/icons/localx.png" "${PACKAGE_ROOT}/usr/share/icons/hicolor/256x256/apps/localx.png"

cat > "${PACKAGE_ROOT}/usr/share/applications/localx.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=LocalX
Comment=Professional local development environment manager
Exec=/opt/localx/localx
Icon=localx
Terminal=false
Categories=Development;
StartupNotify=true
EOF

cat > "${PACKAGE_ROOT}/DEBIAN/control" <<EOF
Package: ${PACKAGE_ID}
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: amd64
Maintainer: MCODERs <legal@mcoders.ir>
Depends: libgtk-3-0, libayatana-appindicator3-1, libnotify4, libsecret-1-0
Description: LocalX local development environment manager for Windows and Linux workflows.
EOF

cat > "${PACKAGE_ROOT}/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
chmod +x /opt/localx/localx || true
ln -sf /opt/localx/localx /usr/local/bin/localx || true
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database >/dev/null 2>&1 || true
fi
exit 0
EOF

cat > "${PACKAGE_ROOT}/DEBIAN/prerm" <<'EOF'
#!/bin/sh
set -e
rm -f /usr/local/bin/localx || true
exit 0
EOF

chmod 0755 "${PACKAGE_ROOT}/DEBIAN/postinst" "${PACKAGE_ROOT}/DEBIAN/prerm"
chmod 0755 "${PACKAGE_ROOT}/opt/localx/localx" || true

dpkg-deb --build --root-owner-group "${PACKAGE_ROOT}" "${OUTPUT_DIR}/${PACKAGE_NAME}"
echo "Built ${OUTPUT_DIR}/${PACKAGE_NAME}"
