FROM alpine

RUN apk add --no-cache openssh-client bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
