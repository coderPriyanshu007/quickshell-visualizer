#!/usr/bin/env bash

set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.config/quickshell/audioframe"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "==> Installing AudioFrame..."

# ------------------------------------------------------------
# Create directories
# ------------------------------------------------------------

mkdir -p "$INSTALL_DIR"
mkdir -p "$SERVICE_DIR"

# ------------------------------------------------------------
# Copy AudioFrame files
# ------------------------------------------------------------

echo "==> Copying AudioFrame files..."

cp "$SOURCE_DIR/shell.qml" \
   "$SOURCE_DIR/Config.qml" \
   "$SOURCE_DIR/AudioFrame.qml" \
   "$SOURCE_DIR/AudioFrameWindow.qml" \
   "$SOURCE_DIR/cava.conf" \
   "$INSTALL_DIR/"

# ------------------------------------------------------------
# Create systemd user service
# ------------------------------------------------------------

echo "==> Creating systemd service..."

cat > "$SERVICE_DIR/audioframe.service" <<EOF
[Unit]
Description=AudioFrame Quickshell Visualizer
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/quickshell -c audioframe
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF

# ------------------------------------------------------------
# Reload systemd
# ------------------------------------------------------------

echo "==> Reloading user systemd..."

systemctl --user daemon-reload

# ------------------------------------------------------------
# Enable at login
# ------------------------------------------------------------

echo "==> Enabling AudioFrame..."

systemctl --user enable audioframe.service

# ------------------------------------------------------------
# Start now
# ------------------------------------------------------------

echo "==> Starting AudioFrame..."

systemctl --user restart audioframe.service

echo
echo "=========================================="
echo " AudioFrame installed successfully!"
echo "=========================================="
echo
echo "Files:"
echo "  $INSTALL_DIR"
echo
echo "Service:"
echo "  audioframe.service"
echo
echo "It will now start automatically when your"
echo "graphical user session starts."
echo
echo "Check status:"
echo "  systemctl --user status audioframe"
echo
echo "Stop:"
echo "  systemctl --user stop audioframe"
echo
echo "Disable autostart:"
echo "  systemctl --user disable audioframe"
echo
