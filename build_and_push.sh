#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
SYNC_SCRIPT="/home/jliu/bb_isaaclab_ws/sync_bb_ws.sh"
CONDA_ENV="env_isaaclab"
IMAGE_LOCAL="isaac-lab-base:latest"
IMAGE_REMOTE="bbjliu6162/isaac-lab-base:latest"

# --- Sync workspace ---
if [[ ! -x "$SYNC_SCRIPT" ]]; then
  echo "Error: sync script not found or not executable: $SYNC_SCRIPT"
  exit 1
fi

echo "Syncing bb_isaaclab_ws..."
"$SYNC_SCRIPT"

# --- Ensure conda is available in non-interactive shell ---
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [[ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]]; then
  source "$HOME/anaconda3/etc/profile.d/conda.sh"
else
  echo "Error: conda.sh not found. Is Conda installed?"
  exit 1
fi

# --- Activate env ---
echo "Activating conda environment: $CONDA_ENV"
conda activate "$CONDA_ENV"

# --- Build image ---
echo "Running Docker build script..."
python ./docker/container.py

# --- Tag image ---
echo "Tagging image..."
docker tag "$IMAGE_LOCAL" "$IMAGE_REMOTE"

# --- Push image ---
echo "Pushing image to Docker Hub..."
docker push "$IMAGE_REMOTE"

echo "✅ Sync, build, and push complete."
