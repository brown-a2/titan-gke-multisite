# Intranet (Kubernetes build)
**k8s** = kubernetes

Downloading and running this repo will launch a Wordpress site with the following configuration:

* A 12 factor Bedrock folder structure - https://roots.io/bedrock/
* Composer driven WP plugin/theme management - https://getcomposer.org/

## Prerequisites

You will need localhost and port 80 free, and the following installed and running on your machine:

* Docker
* Kubernetes
* Helm (reccomend installing via Homebrew) - https://helm.sh/docs/using_helm/#quickstart
* Tiller (a tool to use with Helm but usually has to be installed separately)

You will need to be on Digital's WiFi network or using a Digital VPN account, when launching for the first time or to get updates, as Composer needs to access the whitelisted MoJ plugin repo.

**Recommended:**
- Kubensx command line tool - https://github.com/shyiko/kubensx . This helps with namespacing and switching between k8s clusters. You can install via brew.
- Stern for logging - https://github.com/wercker/stern

**Tip:** 
Docker now has Kubernetes built-in, so if you have Docker running on your machine, you already have Kubernetes!
To "turn-on" go into Docker's `preferences`. More info you can find here https://rominirani.com/tutorial-getting-started-with-kubernetes-with-docker-on-mac-7f58467203fd

If you don't want to use Docker's built in version of Kubernetes, there is an alternative called minicube - https://kubernetes.io/docs/tasks/tools/install-minikube/

## Run instructions

### TL;DR instructions

1. `make launch` in repo root. A vanilla version of WP will be built at `localhost`. Takes a few minutes.
2. `kubens intranet` - Switches you to intranet namespace if you are not in it. Need to have kubensx installed.
2. `make seed` - installs intranet theme and populates intranet db.
3. Intranet should be running on `localhost` - without images :(

### Long(er) instructions

1. Create a folder and download this repo into it.
2. Inside the root of this repo on your local machine run `make launch`. 
This runs a Helm chart that instructs Kubernetes to build the site. In a few mins the site will be up and running at `localhost`.

You can check progress using the k8s command `kubectrl get all` or `kubectrl get pods` or `kubectrl get pods -w` (watches). You will see the pods starting up. If you see nothing you're in the wrong namespace. Run `kubens intranet` - Switches you to intranet namespace if you are not in it. Need to have kubensx installed.

Once you see `1/1` for both the Wordpress and MYSQL pods, you know it's worked successfully. If the pod stays stuck at `0/1` there is an issue. You could try trouble shooting the pod with the following `kubectrl describe [pod name]`. You can also use `stern [pod name]` if you have stern installed to see the logs live streamed.

3. Visiting **localhost:80** you should now see a vanilla Wordpress site with a "Hello World" post.

#### Now you need to setup the intranet theme and load the intranet database.

4. Put a copy of the intranet database in the db-dump folder.
5. Run `make seed` and follow the command line prompts. It takes a few minutes but once the db has loaded, visit localhost again, you should see the intranet with the correct theme.

## Troubleshooting

Problem loading db? Check you are in the right namespace, run the `kubens` command if you have `Kubensx` installed. If you are in the wrong namespace you want to use `kubens [namespace name]` so `kubens intranet`.

If you get a "tiller needs to be installed" kind of message, go into `/helm_charts/wordpress` and run `helm init --history-max 200` which should install tiller.

Make sure you are on Digital's WiFi network or using a Digital VPN account.

## Shutdown instructions
Run `make nuke` to stop and delete everything running in Kubernetes.
If you want to see what you are taking down first, you run `helm list` and then `helm delete [name here]`. What Helm is doing here, is gathering all your kubernetes resources based off your charts and shuting them down. Kind of like deleting a stack in CloudFormations.

## A bit more about the environment:
This uses a base image provided by Bitnami. There are a number of advantages to using Bitnami. See documentation,
https://hub.docker.com/r/bitnami/wordpress-nginx

Besides the base image, the application requires another app level image for modifications, nginx, compiling tools etc. These are found in the repo `Dockerfile`. The image built from this Dockerfile needs to be hosted in the MoJ Docker repo, however for now, as you will see in the Helm chart, I have it in my own repo browna2/intranet-base).

## TODO:
* Mount local folder into k8s for development.
* Configure ingress correctly.
* Configure images to appear.
* Move onto CloudPlatforms using AWS resources.
