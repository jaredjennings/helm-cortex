# Unofficial Helm chart for Cortex

This repository contains a Helm chart that can install
[Cortex](https://github.com/TheHive-Project/Cortex), "a Powerful
Observable Analysis and Active Response Engine," onto a Kubernetes
cluster.

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
helm install .
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
