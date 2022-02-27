# https://mcr.microsoft.com/v2/azure-cli/tags/list
FROM mcr.microsoft.com/azure-cli:2.8.0

# Enable dig to find the runner's public IP
RUN apk update && apk add --no-cache bind-tools

COPY root /
