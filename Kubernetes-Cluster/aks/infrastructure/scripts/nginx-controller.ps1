helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
cd ../../manifests
helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace nginx-controller -f '.\nginx-internal.yaml'
