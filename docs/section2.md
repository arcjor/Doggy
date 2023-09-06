# Section 2 - Implementing persistence with Postgres and running with Docker-Compose

In this section we explain how code generators were used to create some initial data models and interactions and bring us to the `section2` tag.

With this increment a user is able to:
- Run the project in a custom built devcontainer with the `psql` postgres client when we load vscode
- Run the peripheral postgres and pgadmin services using docker-compose from the commandline outside of vscode
- Run the app connected to postgres from the commandline outside of vscode by calling `make run`

## Adding source code for persistence

The [API tutorial](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-7.0&tabs=visual-studio-code#add-a-model-class) steps from 'Add a model class' were followed initially to create data models and controllers. The in-memory database will not function with linux-based dotnet and was swapped out for Postgres persistence.

Dotnet commands for the process included:
```
dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design -v 7.0.0
dotnet add package Microsoft.EntityFrameworkCore.Design -v 7.0.0
dotnet add package Microsoft.EntityFrameworkCore.SqlServer -v 7.0.0
dotnet tool uninstall -g dotnet-aspnet-codegenerator
dotnet tool install -g dotnet-aspnet-codegenerator
dotnet tool update -g dotnet-aspnet-codegenerator
dotnet aspnet-codegenerator controller -name DogController -async -api -m Dog -dc DogContext -outDir Controllers
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
```

Migrations were added to have the runtime autoamtically structure the database correctly:
```
dotnet tool install -g dotnet-ef
dotnet ef migrations add Initial
```

## Adding docker-compose configuration for peripheral services

A docker-compose configuration which runs postgres and pgadmin containers was borrowed from [this tutorial](https://blog.christian-schou.dk/connect-postgresql-database-to-dot-net-6/):
```
cat << EOF > docker-compose.yml
version: '3.5'

services:
  postgres:
    container_name: postgres_db_container
    image: postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
      PGDATA: /data/postgres
    volumes:
       - postgres:/data/postgres
    ports:
      - "5432:5432"
    networks:
      - postgres
    restart: unless-stopped
  
  pgadmin:
    container_name: pgadmin_db_container
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-pgadmin4@pgadmin.org}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-admin}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
       - pgadmin:/var/lib/pgadmin

    ports:
      - "${PGADMIN_PORT:-5050}:80"
    networks:
      - postgres
    restart: unless-stopped

networks:
  postgres:
    driver: bridge

volumes:
    postgres:
    pgadmin:
EOF
```

## Upgrading the devcontainer to include psql

In order to provide the `psql` postgres client the `.devcontainer.json` file was modified to build via dockerfile and augmented with an install script.
