# Experimental project for enabling systemd containers in OpenShift Dev Spaces

__Note:__ The manifests for creating the container image used in the systemd enabled workspace are located in the `workspace-image-systemd-enabled` directory.

## Apply the following MachineConfig to enable RW cgroups

See the following references -

[https://issues.redhat.com/browse/OCPNODE-4115](https://issues.redhat.com/browse/OCPNODE-4115)

[https://issues.redhat.com/browse/CRW-10248](https://issues.redhat.com/browse/CRW-10248)


```bash
# For Control-Plane nodes -
# MACHINE_TYPE=master

# For Compute Nodes -
# MACHINE_TYPE=worker

cat << EOF | butane | oc apply -f -
variant: openshift
version: 4.20.0
metadata:
  labels:
    machineconfiguration.openshift.io/role: ${MACHINE_TYPE}
  name: enable-rw-cgroup-${MACHINE_TYPE}
storage:
  files:
  - path: /etc/crio/crio.conf.d/99-cic-systemd
    mode: 0644
    overwrite: true
    contents:
      inline: |
        [crio.runtime.runtimes.crun]
        runtime_root = "/run/crun"
        allowed_annotations = [
          "io.containers.trace-syscall",
          "io.kubernetes.cri-o.Devices",
          "io.kubernetes.cri-o.LinkLogs",
          "io.kubernetes.cri-o.cgroup2-mount-hierarchy-rw",
        ]
EOF
```

## Apply a Machine Config to patch an issue being fixed in OCP -

[https://issues.redhat.com/browse/RHEL-129122](https://issues.redhat.com/browse/RHEL-129122)

```bash
# For Control-Plane nodes -
# MACHINE_TYPE=master

# For Compute Nodes -
# MACHINE_TYPE=worker

cat << EOF | butane | oc apply -f -
variant: openshift
version: 4.20.0
metadata:
  labels:
    machineconfiguration.openshift.io/role: ${MACHINE_TYPE}
  name: selinux-patch-audit-log-${MACHINE_TYPE}
storage:
  files:
  - path: /etc/selinux_patch_audit_log.te
    mode: 0644
    overwrite: true
    contents:
      inline: |
        module selinux_patch_audit_log 1.0;
        require {
                type container_engine_t;
                class netlink_audit_socket nlmsg_relay;
        }
        #============= container_engine_t ==============
        allow container_engine_t self:netlink_audit_socket nlmsg_relay;
systemd:
  units:
  - contents: |
      [Unit]
      Description=Modify SeLinux Type container_engine_t
      DefaultDependencies=no
      After=kubelet.service

      [Service]
      Type=oneshot
      RemainAfterExit=yes
      ExecStart=bash -c "/bin/checkmodule -M -m -o /tmp/selinux_patch_audit_log.mod /etc/selinux_patch_audit_log.te && /bin/semodule_package -o /tmp/selinux_patch_audit_log.pp -m /tmp/selinux_patch_audit_log.mod && /sbin/semodule -i /tmp/selinux_patch_audit_log.pp"
      TimeoutSec=0

      [Install]
      WantedBy=multi-user.target
    enabled: true
    name: systemd-selinux-patch-audit-log.service
EOF
```

## Create an SCC to allow workspaces CAP_CHOWN

```bash
cat << EOF | oc apply -f -
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: nested-podman-systemd
priority: null
allowPrivilegeEscalation: true
allowedCapabilities:
- SETUID
- SETGID
- CHOWN
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1000
    max: 65534
runAsUser:
  type: MustRunAs
  uid: 1000
seLinuxContext:
  type: MustRunAs
  seLinuxOptions:
    type: container_engine_t
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1000
    max: 65534
userNamespaceLevel: RequirePodLevel
EOF
```

## Install OpenShift Dev Spaces

```bash
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: devspaces
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: devspaces
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Create the Dev Spaces cluster

```bash
cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: devspaces
---
apiVersion: org.eclipse.che/v2
kind: CheCluster
metadata:
  name: devspaces
  namespace: devspaces
spec:
  components:
    cheServer:
      debug: false
      logLevel: INFO
    metrics:
      enable: true
    pluginRegistry:
      openVSXURL: https://open-vsx.org
    devfileRegistry:
      disableInternalRegistry: true
  containerRegistry: {}
  devEnvironments:
    startTimeoutSeconds: 600
    secondsOfRunBeforeIdling: -1
    maxNumberOfWorkspacesPerUser: -1
    maxNumberOfRunningWorkspacesPerUser: 5
    disableContainerRunCapabilities: false
    security:
    containerRunConfiguration:
      openShiftSecurityContextConstraint: nested-podman-systemd
      containerSecurityContext:
        allowPrivilegeEscalation: true
        procMount: Unmasked
        runAsUser: 1000
        capabilities:
          add:
          - SETGID
          - SETUID
          - CHOWN
      workspacesPodAnnotations:
        io.kubernetes.cri-o.Devices: "/dev/fuse,/dev/net/tun"
        io.kubernetes.cri-o.cgroup2-mount-hierarchy-rw: 'true'
    defaultComponents:
    - name: dev-tools
      container:
        image: quay.io/cgruver0/che/dev-tools:latest
        memoryLimit: 6Gi
        mountSources: true
    defaultEditor: che-incubator/che-code/latest
    defaultNamespace:
      autoProvision: true
      template: <username>-devspaces
    secondsOfInactivityBeforeIdling: 1800
    storage:
      pvcStrategy: per-workspace
  gitServices: {}
  networking: {}
EOF
```

## Create a workspace from this repo

Create the workspace using the `devfile-systemd.yaml` Devfile.

## Run a container with systemd

```bash
podman run -d --name=systemd registry.access.redhat.com/ubi10-init:10.1
```

## Build and run a container that enables Nginx with systemd

```bash
podman build -t systemd:nginx ./systemd-test-image

podman run -d -p 8080:80 --name=nginx systemd:nginx
```
