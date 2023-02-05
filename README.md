### Create the external network
```shell
openstack network create kubespray --share --provider-network-type vlan --provider-physical-network clabext01 --provider-segment 100
openstack subnet create --network kubespray --dns-nameserver 10.2.1.30 --gateway 10.5.0.1 --subnet-range 10.5.0.0/24 kubespray
openstack subnet set kubespray --no-allocation-pool
openstack subnet set kubespray --allocation-pool start=10.5.0.10,end=10.5.0.60

```
### Create vms:
```bash
CWD=`pwd`
cd terraform
terraform init
terraform destroy --auto-approve
terraform apply --auto-approve
terraform apply --auto-approve
terraform apply --auto-approve
terraform apply --auto-approve
terraform apply --auto-approve
terraform apply --auto-approve
openstack volume list | grep available | awk '{print $2}' | xargs openstack volume delete
```

## Configure inventory:
```bash
cd ../scripts/
./inventory.py
```

## Deploy k8s:
```bash
cd ../ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts build.yml
```

## Test with mysql
```shell
kubectl create namespace test
kubectl config set-context --current --namespace=test
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mysql bitnami/mysql
# helm install mysql bitnami/mysql --set global.persistence.storageClass=nfs --set primary.persistence.storageClass=nfs --set secondary.persistence.storageClass=nfs
kubectl get pods
kubectl expose service mysql --type=LoadBalancer --name=mysql-exposed
ipaddr=`kubectl get service mysql-exposed -o  jsonpath='{.status.loadBalancer.ingress[0].ip}'`
MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace test mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
mysql -h ${ipaddr} -uroot -p"${MYSQL_ROOT_PASSWORD}"
```

## Test with elasticsearch

[Reference](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html)


```shell

#kubectl create namespace elastic
#kubectl config set-context --current --namespace=elastic

# Install custom resource definitions and the operator with its RBAC rules:
kubectl create -f https://download.elastic.co/downloads/eck/2.0.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.0.0/operator.yaml

# Monitor the operator logs:
kubectl -n elastic-system logs -f statefulset.apps/elastic-operator
kubectl -n elastic-system get pods

# Deploy cluster:

cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 8.0.0
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
EOF

kubectl get elasticsearch
kubectl get pods

# Get elasticsearch access
kubectl get service quickstart-es-http

kubectl expose service quickstart-es-http --type=LoadBalancer --name=quickstart-es-http-exposed
ipaddr=`kubectl get service quickstart-es-http-exposed -o  jsonpath='{.status.loadBalancer.ingress[0].ip}'`
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
curl -u "elastic:$PASSWORD" -k "https://${ipaddr}:9200/"
curl -u "elastic:$PASSWORD" -k "https://${ipaddr}:9200/_cat/nodes?v"

# Kibana
cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
spec:
  version: 8.0.0
  count: 1
  elasticsearchRef:
    name: quickstart
EOF

kubectl get kibana
kubectl get pod --selector='kibana.k8s.elastic.co/name=quickstart'

# Access kibana
kubectl get service quickstart-kb-http
kubectl expose service quickstart-kb-http --type=LoadBalancer --name=quickstart-kb-http-exposed
ipaddr=`kubectl get service quickstart-kb-http-exposed -o  jsonpath='{.status.loadBalancer.ingress[0].ip}'`
pass=`kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo`
echo "USER: elastic"
echo "PASS: ${pass}"
chromium  https://${ipaddr}:5601 >/dev/null 2>&1&


# Upgrade:
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 8.0.0
  nodeSets:
  - name: default
    count: 3
    config:
      node.store.allow_mmap: false
EOF

```

Queries (using kibana):
```shell
GET /_cat/nodes?v
```


## Other test: Create a nginx deployment and expose it:
```
kubectl create deployment nginx --image=nginx
kubectl delete service my-service
cat << EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

kubectl apply -f service.yaml
kubectl expose service my-service --type=LoadBalancer --name=my-service-exposed
kubectl get service
```