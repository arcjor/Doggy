# Section 3 - Implementing deployment mechanisms with Docker and Azure CLI features

In this section we explain how scripts were created to deploy the app to the cloud by leveraging the Azure CLI and bring us to the `section3` tag.

With this increment a user is able to:
- Run the existing `make` commands from within the devcontainer
- Run a `make upload` command to push the application image to an Azure Container Registry, creating it if it does not exist
- Run a `make deploy` command to run the application as an Azure Container App, creating the environment if it does not exist

## Adding features for Docker and Azure CLI to the devcontainer

In this increment the `.devcontainer.json` file was modified to add a `features` block.
A default entry was added to add the `docker-outside-of-docker` feature, and an `azure-cli` entry was added which also specified the inclusion of the `containerapp` CLI extension.
The devcontainer dockerfile now also copies the scripts supporting these commands into the image.

## Creating supporting scripts to allow image uploading to Azure

A pair of scripts were created to upload and deploy the image built with the `make build` command.

These scripts use straightforward `az` to ensure the underlying infrastructure is created, `docker` to upload the image, and `az` again to bring the application to runtime in an Azure Container App.
