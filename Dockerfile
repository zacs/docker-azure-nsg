# https://mcr.microsoft.com/v2/azure-cli/tags/list
FROM mcr.microsoft.com/azure-cli:2.8.0

COPY update_nsg.sh /update_nsg.sh
COPY cron.sh /cron.sh

RUN chmod +x ./update_nsg.sh
RUN chmod +x ./cron.sh

# Install dig and cron
RUN apk update && apk add --no-cache bind-tools

# Add cronjob
RUN crontab -l | { cat; echo "*/5 * * * * bash /update_nsg.sh"; } | crontab -

ENTRYPOINT [ "/cron.sh" ]