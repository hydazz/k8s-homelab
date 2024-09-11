#!/bin/bash

# Script to migrate data to a Kubernetes PVC

# Set variables based on user input
NAMESPACE=$1
PVC_NAME=$2
DEPLOYMENT_NAME=$3
DEST_PATH=$4
LOCAL_PATH=$5

# Deploy a temporary Pod that mounts the PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: migrator-pod
  namespace: media-downloaders
spec:
  containers:
  - name: migrator
    image: alpine
    volumeMounts:
    - name: vol
      mountPath: /mnt
    command: ["/bin/sh", "-c", "while true; do sleep 30; done"]
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: qbittorrent-appdata-pvc
  restartPolicy: Never
EOF

# Wait for the Pod to be ready
echo "Waiting for migrator Pod to be ready..."
kubectl wait --for=condition=ready pod migrator-pod -n media-downloaders

# Scale down the target deployment
kubectl scale deployment qbittorrent --replicas=0 -n media-downloaders

# Optionally, clear the destination path
kubectl exec migrator-pod -n media-downloaders -- rm -rf /mnt/$DEST_PATH/*

# Copy data to the PVC
echo "Copying data to the PVC..."
kubectl cp $LOCAL_PATH media-downloaders/migrator-pod:/mnt/$DEST_PATH

# Clean up: Delete the migrator Pod
kubectl delete pod migrator-pod -n media-downloaders

# Scale up the target deployment
kubectl scale deployment qbittorrent --replicas=1 -n media-downloaders

echo "Data migration completed successfully."
