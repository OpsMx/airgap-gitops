# Docker Tag
docker tag quay.io/opsmxpublic/ubi8-gate:v3.9.1.2  PRIV-REGISTRY/ubi8-gate:v3.9.1.2
docker tag quay.io/opsmxpublic/ubi8-oes-autopilot:v3.9.1.2  PRIV-REGISTRY/ubi8-oes-autopilot:v3.9.1.2
docker tag quay.io/opsmxpublic/ubi8-oes-dashboard:v3.9.1.2  PRIV-REGISTRY/ubi8-oes-dashboard:v3.9.1.2
docker tag quay.io/opsmxpublic/ubi8-oes-platform:v3.9.1.3  PRIV-REGISTRY/ubi8-oes-platform:v3.9.1.3
docker tag quay.io/opsmxpublic/ubi8-oes-sapor:v3.9.1.2  PRIV-REGISTRY/ubi8-oes-sapor:v3.9.1.2
docker tag quay.io/opsmxpublic/ubi8-oes-ui:v3.9.1.2  PRIV-REGISTRY/ubi8-oes-ui:v3.9.1.2
docker tag quay.io/opsmxpublic/ubi8-oes-visibility:v3.9.1.2  PRIV-REGISTRY/ubi8-oes-visibility:v3.9.1.2
docker tag quay.io/opsmxpublic/forwarder-controller:v20210722T133815  PRIV-REGISTRY/forwarder-controller:v20210722T133815
docker tag quay.io/opsmxpublic/forwarder-agent:v20210722T133815  PRIV-REGISTRY/forwarder-agent:v20210722T133815
docker tag minio/mc:RELEASE.2020-11-25T23-04-07Z  PRIV-REGISTRY/minio/mc:RELEASE.2020-11-25T23-04-07Z


# Docker Push
docker push PRIV-REGISTRY/ubi8-gate:v3.9.1.2
docker push PRIV-REGISTRY/ubi8-oes-autopilot:v3.9.1.2
docker push PRIV-REGISTRY/ubi8-oes-dashboard:v3.9.1.2
docker push PRIV-REGISTRY/ubi8-oes-platform:v3.9.1.3
docker push PRIV-REGISTRY/ubi8-oes-sapor:v3.9.1.2
docker push PRIV-REGISTRY/ubi8-oes-ui:v3.9.1.2
docker push PRIV-REGISTRY/ubi8-oes-visibility:v3.9.1.2
docker push PRIV-REGISTRY/forwarder-controller:v20210722T133815
docker push PRIV-REGISTRY/forwarder-agent:v20210722T133815
docker push PRIV-REGISTRY/minio/mc:RELEASE.2020-11-25T23-04-07Z

