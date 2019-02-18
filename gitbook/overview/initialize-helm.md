# Initialize Helm

Initialize Helm on your cluster

```bash
$ helm init

$HELM_HOME has been configured at /Users/svennam/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.
Happy Helming!
```

The command above will install helm for your kubernetes cluster and also store the cofig to your local directory. It will also install tiller in the cluster. _**Tiller**_ is the in-cluster component of Helm. It interacts directly with the Kubernetes API server to _install_, _upgrade_, _query_, and _remove_ Kubernetes resources. It also stores the objects that represent releases.

Check helm is properly installed

```bash
$ helm version

Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
```

