# Doggy - A Dotnet 7 API leveraging a Docker and Devcontainer Ecosystem

This repository is a documented example of leveraging a Docker ecosystem to develop dotnet software.
All material is sourced from referenced official documentation or tutorials. The repository is constructed in sections, each of which introduces additional concepts around containerized SDLC.

In order to exercise all content within this repository the following software is needed:
* VSCode
* Docker
* Docker Compose

The content in this repository makes use of technologies including:
* Dotnet Docker Containers
* VSCode with DevContainers
* Entity Framework and PostgreSQL
* Docker-compose orchestrated PostgreSQL and PGAdmin
* Azure CLI and Cloud Capabilities

## Sections

[Section 1](docs/section1.md) - Creating the initial REST API serving ephemeral data

[Section 2](docs/section2.md) - Implementing persistence with Postgres


<p align="right">(<a href="#top">back to top</a>)</p>

## References
[First-web-api tutorial](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api) - A tutorial by microsoft explaining how to build a dotnet REST API
[Devcontainers VSCode official docs](https://code.visualstudio.com/docs/devcontainers/containers) - The VSCode page describing how devcontainers work
[Containerizing a dotnet app](https://learn.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=linux)
