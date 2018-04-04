SHELL := /bin/bash
FORTIO_POD := $(kubectl get pods | grep fortio | awk '{ print $1 }')

rrc:
	kubectl apply -f ../scripts/samples/bookinfo/kube/route-rule-all-v1.yaml

rr1:
	kubectl apply -f ../scripts/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml

rrclean:
	kubectl delete -f ../scripts/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml

rt1:
	kubectl apply -f ./v2reviews.yaml

rt2:
	kubectl apply -f ./2secratings.yaml

rt3:
	kubectl apply -f ./1secreviews.yaml

rtclean:
	kubectl delete -f ../scripts/samples/bookinfo/kube/route-rule-all-v1.yaml
	kubectl delete -f ./2secratings.yaml
	kubectl delete -f ./1secreviews.yaml

ct1:
	kubectl apply -f ../scripts/samples/httpbin/httpbin.yaml

ct2:
	kubectl apply -f ../scripts/samples/httpbin/routerules/httpbin-v1.yaml
	kubectl apply -f ../scripts/samples/httpbin/destinationpolicies/httpbin-circuit-breaker.yaml

ct3:
	kubectl create -f ../scripts/samples/httpbin/sample-client/fortio-deploy.yaml

ct4:
	# FORTIO_POD=$(kubectl get pods | grep fortio | awk '{ print $1 }')
	kubectl exec -it fortio-deploy-75cc8dd9d4-6clkr -c fortio /usr/local/bin/fortio -- load -curl  http://httpbin:8000/get

ct5:
	# FORTIO_POD=$(kubectl get pod | grep fortio | awk '{ print $1 }')
	kubectl exec -it fortio-deploy-75cc8dd9d4-6clkr -c fortio /usr/local/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get

ct6:
	# FORTIO_POD=$(kubectl get pod | grep fortio | awk '{ print $1 }')
	kubectl exec -it fortio-deploy-75cc8dd9d4-6clkr -c fortio /usr/local/bin/fortio -- load -c 3 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get

ctclean:
	kubectl delete -f ../scripts/samples/httpbin/routerules/httpbin-v1.yaml
	kubectl delete -f ../scripts/samples/httpbin/destinationpolicies/httpbin-circuit-breaker.yaml
