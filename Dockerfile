ARG DEBIAN_VERSION=buster-slim
ARG MSKTUTIL_VERSION=1.2.1

FROM debian:${DEBIAN_VERSION} as msktutil_builder

ARG MSKTUTIL_VERSION

RUN apt update -y && apt install -y \
            gcc \
            g++ \
            make \
            libkrb5-dev \
            libsasl2-dev \
            libldap2-dev \
            curl

WORKDIR /src

RUN curl -kLO https://github.com/msktutil/msktutil/releases/download/${MSKTUTIL_VERSION}/msktutil-${MSKTUTIL_VERSION}.tar.gz \
    && tar -xf msktutil-${MSKTUTIL_VERSION}.tar.gz \
    && cd msktutil-${MSKTUTIL_VERSION}/ \
    && ./configure \
    && make \
    && make install

FROM debian:${DEBIAN_VERSION}

ARG REALM
ARG ADMIN_SERVER
ARG KDC_SERVER

RUN apt update -y && DEBIAN_FRONTEND=noninteractive apt install -y \
            krb5-user \
            openssl \
            libldap2-dev \
            libsasl2-modules-gssapi-mit

COPY --from=msktutil_builder /usr/local/sbin/msktutil /usr/local/sbin/
COPY ./krb5.conf /etc/krb5.conf
COPY ./update-krb5-conf.sh /usr/local/sbin/update-krb5-conf
RUN chmod +x /usr/local/sbin/update-krb5-conf

WORKDIR /keytab


