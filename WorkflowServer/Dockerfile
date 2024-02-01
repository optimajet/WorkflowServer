FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ./WorkflowServer WorkflowServer/
RUN dotnet restore WorkflowServer/WorkflowServer.csproj --source https://api.nuget.org/v3/index.json
WORKDIR /src/WorkflowServer
RUN dotnet build WorkflowServer.csproj -c Release -o /app

FROM build AS publish
WORKDIR /src/WorkflowServer
RUN dotnet publish WorkflowServer.csproj -c Release -o /app

FROM base AS final
WORKDIR /app/wfs
COPY --from=publish /app ./bin
COPY ./backend ./backend
COPY ./frontend ./frontend
COPY ./config.json .

RUN useradd --user-group --uid 1000 wfs
RUN chown -R wfs:wfs /app

USER wfs

WORKDIR /app/wfs/bin
ENTRYPOINT ["dotnet", "WorkflowServer.dll"]