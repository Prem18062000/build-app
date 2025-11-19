#!/usr/bin/env bash
set -euxo pipefail

MASTER_IP="98.87.149.104"
JENKINS_URL="http://${MASTER_IP}:8080"
AGENT_SECRET="28bc2ff65c61ff25abb9c28f3877ba1b2a74d048c008f7adf15d8f729676cce0"
AGENT_NAME="project_1_dev"
WORKDIR="/home/ubuntu/jenkins-agent"
SERVICE_FILE="/etc/systemd/system/jenkins-agent.service"

# Stop & cleanup any running agent processes and service
sudo systemctl stop jenkins-agent 2>/dev/null || true
sudo systemctl disable jenkins-agent 2>/dev/null || true
sudo pkill -f "agent.jar" || true
sleep 1

# Ensure working dir exists and permissions are correct
sudo mkdir -p "${WORKDIR}"
sudo chown -R ubuntu:ubuntu "${WORKDIR}"
sudo chmod 755 "${WORKDIR}"

# Download agent.jar from Jenkins master (overwrite if exists)
cd "${WORKDIR}"
curl -s -o agent.jar "${JENKINS_URL}/jnlpJars/agent.jar"
if [ ! -f agent.jar ]; then
  echo "ERROR: Failed to download agent.jar from ${JENKINS_URL}/jnlpJars/agent.jar"
  exit 1
fi
sudo chown ubuntu:ubuntu agent.jar
sudo chmod 644 agent.jar

# Remove any existing broken service file
sudo rm -f "${SERVICE_FILE}"

# Create a clean, single-line ExecStart service file (no wrapping)
sudo bash -c "cat > ${SERVICE_FILE}" <<'SERVICE_EOF'
[Unit]
Description=Jenkins Agent Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/jenkins-agent
ExecStart=/usr/bin/java --add-opens=java.base/java.lang=ALL-UNNAMED --enable-native-access=ALL-UNNAMED -jar /home/ubuntu/jenkins-agent/agent.jar -url http://98.87.149.104:8080/ -secret 28bc2ff65c61ff25abb9c28f3877ba1b2a74d048c008f7adf15d8f729676cce0 -name project_1_dev -webSocket -workDir /home/ubuntu/jenkins-agent
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Remove any stray CRLF characters that could break systemd parsing
sudo sed -i 's/\r$//' "${SERVICE_FILE}"
sudo chmod 644 "${SERVICE_FILE}"

# Verify service file content (show ExecStart line)
echo "---- service file ExecStart (for verification) ----"
sudo grep -n "^ExecStart" -n "${SERVICE_FILE}" || true
echo "--------------------------------------------------"

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable jenkins-agent
sudo systemctl reset-failed jenkins-agent
sudo systemctl start jenkins-agent

# Wait a moment for the agent to attempt connection
sleep 3

# Show service status and latest journal lines for debugging
echo
sudo systemctl status jenkins-agent --no-pager -l
echo
echo "---- Last 80 lines of journal for jenkins-agent ----"
sudo journalctl -u jenkins-agent -n 80 --no-pager
