# Unofficial Helm chart for Cortex

This repository contains a Helm chart that can install
[Cortex](https://github.com/TheHive-Project/Cortex), "a Powerful
Observable Analysis and Active Response Engine," onto a Kubernetes
cluster.

## Prerequisites

* Kubernetes 1.19+
* Helm 3.5.2
* A PersistentVolume with accessModes `ReadWriteMany`
* A nonstandard build of Cortex (read on)

## Trying it out

Cortex is flexible in the way it runs analysis and response jobs, but
mainline Cortex doesn't support running jobs using Kubernetes Jobs as
of this writing. See
https://github.com/TheHive-Project/Cortex/issues/347,
https://github.com/TheHive-Project/Cortex/pull/349, and
https://j.agrue.info/cortex-on-kubernetes.html for more on this. I
have an unofficial, unsupported build with the code in the pull
request at https://hub.docker.com/r/jaredjennings/cortex .

With that out of the way, it's also early days for this chart, but if
you want to try it out, clone this repository, cd into it, and

```
helm install mycortex .
```

You'll need to customize the values.yaml or provide some `--set`
command line options, of course. On my single-node home k3s 1.20.2
cluster with stock Traefik 1.7 and Helm 3.5.2, this does the trick for
me:

```
helm install -n cortex my-cortex . \
             --set image.repository=jaredjennings/cortex \
             --set jobIOStorage.pvc.storageClass=manual \
             --set 'ingress.hosts[0].host=cortexfoo.k.my.dns.domain' \
             --set 'ingress.hosts[0].paths[0].path=/'
```

## What? a manual PVC?

As detailed in the other pages linked above, a ReadWriteMany volume is
required, which is a bit of an oddity. k3s' local-path storage class,
for example, does not support this access mode. So on my single-node
home cluster, I had to manually create a persistent volume to back
this claim before everything would spin up, like so:

```
kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: cortex
  name: cortex-hppv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/data"
...
<Ctrl-D>
```

And of course I had to create the directory `/mnt/data` too.

Resources about ReadWriteMany volumes are pointed to in the discussion on the Cortex issue.


## Improving the chart

If this chart doesn't flex in a way you need it to, and there isn't already an issue about it, please file one.

If you can see your way to making an improvement, shoot a pull request over.


## The future

I hope that one day this chart and its peers will be part of the
solution to https://github.com/TheHive-Project/TheHive/issues/1224. 

# Parameters

## Elasticsearch

| Parameter                            | Description                                                            | Default               |
| ---------                            | -----------                                                            | -------               |
| elasticsearch.eck.enabled            | Set this to true if you used ECK to set up an Elasticsearch cluster.   | false                 |
| elasticsearch.eck.name               | Set to the name of the `Elasticsearch` custom resource.                | nil                   |
| elasticsearch.external.enabled       | Set this to true if you have a non-ECK Elasticsearch server/cluster.   | false                 |
| elasticsearch.username               | Username with which to authenticate to Elasticsearch.                  | elastic<sup>1,2</sup> |
| elasticsearch.userSecret             | Secret containing the password for the named user.                     | nil<sup>1</sup>       |
| elasticsearch.url                    | URL to Elasticsearch server/cluster.                                   | nil<sup>1</sup>       |
| elasticsearch.tls                    | Set this to true to provide a CA cert to trust.                        | true<sup>1</sup>      |
| elasticsearch.caCertSecret           | Secret containing the CA certificate to trust.                         | nil<sup>1,3</sup>     |
| elasticsearch.caCertSecretMappingKey | Name of the key in the caCertSecret whose value is the CA certificate. | "ca.crt"<sup>1,3</sup>     |
| elasticsearch.caCert                 | PEM text of the CA cert to trust.                                      | nil<sup>1,3</sup>     |

Notes:

1. If you use ECK to set up an Elasticsearch cluster, you don't need
   to specify this.
2. The user secret should be an opaque secret, with data whose key is
   the username and value is the password.
3. The `caCertSecret` should be an opaque secret with a key named by
   `caCertSecretMappingKey` whose value is the PEM-encoded
   certificate. It could have other keys and values. If you don't have
   such a secret already, you can provide the PEM-encoded certificate
   itself as the `elasticsearch.caCert` value, and the secret will be
   constructed for you.
   
## Job I/O storage

Cortex sends inputs to analyzers and receives reports back via files
stored on a persistent volume it shares with the jobs. These are the
parameters for that filesystem. It's created with the ReadWriteMany
access mode, which tells the cluster that both the Cortex pod and the
analyzer/responder job pod will need to be able both to read and write
this volume. Far fewer storage drivers support this mode than
ReadWriteOnce, but at least one should support you. You may have to
manually create the PersistentVolume that backs this claim.

| Parameter                     | Description                                                            | Default          |
| --                            | --                                                                     | --               |
| jobIOStorage.pvc.enabled      | Set this to true to use a persistent volume claim for job I/O storage. | true             |
| jobIOStorage.pvc.storageClass | Name a storage class to use for the persistent volume claim.           | "default"        |
| jobIOStorage.pvc.size         | Size of the job I/O storage.                                           | 10Gi<sup>1</sup> |

Notes:

1. You should have at least enough storage for every analysis/response
   job that might be in flight at once. Many inputs will be tiny
   snippets of text such as hashes or email addresses; but some may be
   entire files: for example, you may wish to use an analyzer to
   detonate in a sandbox a large PDF found attached to a dubious
   email. When everything goes properly, files are deleted after the
   job is over.
