 JAEGER_URL="http://jaeger-query-istio-system.127.0.0.1.nip.io"
 GRAFANA_URL="http://grafana-istio-system.127.0.0.1.nip.io"
 VERSION_LABEL="v0.10.0"

 curl https://raw.githubusercontent.com/kiali/kiali/${VERSION_LABEL}/deploy/kubernetes/kiali-configmap.yaml | \
 VERSION_LABEL=${VERSION_LABEL} \
 JAEGER_URL=${JAEGER_URL}  \
 ISTIO_NAMESPACE=istio-system  \
 GRAFANA_URL=${GRAFANA_URL} envsubst | kubectl create -n istio-system -f -

 curl https://raw.githubusercontent.com/kiali/kiali/${VERSION_LABEL}/deploy/kubernetes/kiali-secrets.yaml | \
 VERSION_LABEL=${VERSION_LABEL} envsubst | kubectl create -n istio-system -f -

 curl https://raw.githubusercontent.com/kiali/kiali/${VERSION_LABEL}/deploy/kubernetes/kiali.yaml | \
 VERSION_LABEL=${VERSION_LABEL}  \
 IMAGE_NAME=kiali/kiali \
 IMAGE_VERSION=${VERSION_LABEL}  \
 NAMESPACE=istio-system  \
 VERBOSE_MODE=4  \
 IMAGE_PULL_POLICY_TOKEN="imagePullPolicy: Always" envsubst | kubectl create -n istio-system -f -
