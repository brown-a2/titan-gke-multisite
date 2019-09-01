launch:
	helm install --namespace=intranet ./helm_charts/wordpress

# load an wordpress database (.sql file). Make sure to a a .sql file in the /db-dump folder 
seed:
	bin/db-seed.sh

# instead of loading an .sql, load some dummy data
populate-dummy-data:
	bin/populate-dummy-data.sh

nuke:
	helm ls --all --short | xargs -L1 helm delete

purge:
	helm ls --all --short | xargs -L1 helm delete --purge

# K8s built in dashboard (use for the Dev env only)
# How to use
# Go to the proxy address created by kubectl proxy, it will ask for a token. To get token run...
# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
dashboard:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
	kubectl proxy
	
