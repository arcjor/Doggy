# Section 1 - Creating the REST API serving ephermeral data

In this section we explain how Dotnet 7 in a Docker containers was be used to scaffold this containerized API and bring us to the `section1` tag.

## Project creation

First the base files were created using the `dotnet new webapi` command used in the [first-web-api tutorial](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api). The commands were run from inside a contianer to remove the need for locally installed dependencies:

From the parent directory of our repository: `docker run --rm -v ".:/app" -w /app mcr.microsoft.com/dotnet/sdk:7.0 dotnet new webapi -o Doggy`

Because the docker container was run in the context of an elevated user the `sudo chmod -R 777 Doggy` command was used to ensure all files are available for editing.

A dotnet gitignore was added by running the `dotnet new gitignore` command within the project directory to prevent unnecessary files from being committed:
`docker run --rm -v ".:/app" -w /app mcr.microsoft.com/dotnet/sdk:7.0 dotnet new gitignore`

If the project were opened in VSCode at this point in time an error would be presented about not having a copy of the dotnet SDK installed, but no local install is necessary even for editing.
In order to solve this problem [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers) were leveraged to pull in exact dependencies appropriate for our project, based on a version controlled configuration.

The [dotnet devcontainer](https://mcr.microsoft.com/en-us/product/devcontainers/dotnet/about) image was first used directly with no modifications.

This was accomplished by creating a file `.devcontainer/devcontainer.json` with the following content:
```
{
    "image": "mcr.microsoft.com/devcontainers/dotnet:7.0"
}
```

VSCode was restarted inside the devcontainer, and from this point forward all actions within the IDE were performed in the context of our devcontainer.

The `dotnet add package Microsoft.EntityFrameworkCore.InMemory` command described in the [first-web-api tutorial](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api) was run from the devcontainer to add the missing dependency.

The program.cs file was also modified to always enable swagger and to remove the HTTPS redirection - it is assumed that this service will have HTTPS offloaded to the hosting platform.

## Building the project in a Docker container

With a bootstrapped dotnet API source project completed, it was now be possible to build an executable Docker container containing this functionality.

A container was built with the following 'Dockerfile', based on the one from the [Containerize a .NET app](https://learn.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=linux) tutorial:
```
cat << EOF > Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /App

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /App
COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "Doggy.dll"]
EOF
```

A makefile was created which may be called from the commandline outside the IDE to manage the application. The `docker build -t doggy .` command will build the container and `docker run --rm -p 8080:80 doggy` will run it.
