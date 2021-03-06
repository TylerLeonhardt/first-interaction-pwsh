FROM mcr.microsoft.com/powershell:lts-alpine-3.10
SHELL ["pwsh", "-Command"]

RUN Install-Module PowerShellForGitHub,GitHubActions -Force -Scope AllUsers

COPY LICENSE README.md /

COPY entrypoint.ps1 /entrypoint.ps1
COPY github.psm1 /github.psm1

ENTRYPOINT ["pwsh", "-Command", "/entrypoint.ps1"]
