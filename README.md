# helm-kgc

A helm plugin to retrieve values from a ConfigMap. Just wrapper for restricted kubctl commands.

Only exists because I want to retrieve helm values from a configmap to be used in an ArgoCD App and building a binary seems overkill

Usage: `helm kgc ConfigmapName`

## Custom Tool Install

eg:


```sh

kubectl patch role argocd-repo-server -n argocd --type=json --patch-file json-patch-sa.yaml

kubectl patch deployment argocd-repo-server -n  argocd --type json --patch-file json-patch-deploy.yaml

```



Add ` --dry-run --output yaml` to validate patch beforehand

**json-patch-deploy.yaml**

```yaml

- op: add
  path: "/spec/template/spec/volumes/-"
  value:
    name: "custom-tools"
    emptyDir: {}
- op: add
  path: "/spec/template/spec/containers/0/env/-"
  value:
    name: "HELM_PLUGINS"
    value: "/custom-tools/helm-plugins/"
- op: add
  path: "/spec/template/spec/containers/0/volumeMounts/-"
  value:
    mountPath: /custom-tools
    name: custom-tools
- op: add
  path: "/spec/template/spec/initContainers/-"
  value:
    name: download-tools
    args:
    - |
      mkdir -p /custom-tools/helm-plugins
      helm plugin install https://github.com/jrhoward/helm-kgc || true
    command:
    - sh
    - -ec
    image: alpine/helm:latest
    imagePullPolicy: IfNotPresent
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /custom-tools
      name: custom-tools
    env:
    - name: HELM_PLUGINS
      value: /custom-tools/helm-plugins
```

**json-patch-sa.yaml**

```yaml

- op: add
  path: "/rules/-"
  value:
    apiGroups:
    - ""
    resources:
    - configmaps
    verbs:
    - get

```

## Sample plugin usage

Add to argocd-cm ConfigMap.

```yaml

  configManagementPlugins: |
    - name: argo-helm-parameters
      init:
        command: ["sh", "-c"]
        args:
          - "helm repo add ${ARGOCD_APP_NAME} ${ARGOCD_APP_SOURCE_REPO_URL} && helm kgc ${ARGOCD_APP_NAME}> extra-params-kgc.yaml"

      generate:
        command: ["sh", "-c"]
        args:
          - "helm template ${ARGOCD_ENV_HELM_RELEASE_NAME} --version=${ARGOCD_APP_REVISION} -n ${ARGOCD_APP_NAMESPACE}  -f extra-params-kgc.yaml ${ARGOCD_APP_NAME}/${ARGOCD_ENV_HELM_CHART}"

```