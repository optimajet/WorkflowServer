FROM microsoft/dotnet:2.1-runtime AS base
WORKDIR /app

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY ./WorkflowServer WorkflowServer/
RUN dotnet restore WorkflowServer/WorkflowServer.csproj --source https://api.nuget.org/v3/index.json
WORKDIR /src/WorkflowServer
RUN dotnet build WorkflowServer.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish WorkflowServer.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app ./bin
COPY ./backend ./backend
COPY ./frontend ./frontend
COPY ./config.json .

WORKDIR /app/bin
ENTRYPOINT ["dotnet", "WorkflowServer.dll"]
