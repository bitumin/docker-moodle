FROM nginx:alpine

RUN	apk update \
    && apk add --update openssl \
    && mkdir /etc/nginx/certificates \
    && openssl req \
		-x509 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/certificates/key.pem \
		-out /etc/nginx/certificates/cert.pem \
		-days 365 \
		-nodes \
		-subj /CN=localhost \
    && rm -rf /var/cache/apk/*
