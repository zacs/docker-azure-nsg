# https://mcr.microsoft.com/v2/azure-cli/tags/list
FROM mcr.microsoft.com/azure-cli:2.8.0

COPY update_nsg.sh /update_nsg.sh

RUN chmod +x ./update_nsg.sh

# Install dig and cron
RUN apk update && apk add --no-cache bind-tools

# Add cronjob
RUN crontab -l | { cat; echo "*/5 * * * * bash /update_nsg.sh"; } | crontab -

CMD [ "exec", “crond”, “-l”, “2”, “-f” ]
