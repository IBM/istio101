# Bookinfo Sample

See <https://istio.io/docs/guides/bookinfo.html>.

## Build docker images without pushing

```shell
src/build-services.sh <version>
```

The bookinfo versions are different from Istio versions since the sample should work with any version of Istio.

## Update docker images in the yaml files

```shell
sed -i "s/\(istio\/examples-bookinfo-.*\):[[:digit:]]\.[[:digit:]]\.[[:digit:]]/<your docker image with tag>/g" */bookinfo*.yaml
```

## Push docker images to docker hub

One script to build the docker images, push them to docker hub and to update the yaml files

```shell
build_push_update_images.sh <version>
```

## Tests

Bookinfo is tested by e2e smoke test on every PR. More info aobut the Bookinfo example can be found [here](https://github.com/istio/istio/blob/master/samples/bookinfo/README.md).
