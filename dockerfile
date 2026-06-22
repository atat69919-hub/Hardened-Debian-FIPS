# syntax=docker/dockerfile:1.6

ARG BASE_IMAGE="debian:trixie-slim"
ARG FIPS_VERSION="3.5.6"
ARG CORE_VERSION="3.5.6"

ARG ACL_VER
ARG ATTR_VER
ARG BASE_FILES_VER
ARG BASH_VER
ARG CA_CERTIFICATES_VER
ARG COREUTILS_VER
ARG DEBCONF_VER
ARG DEBIANUTILS_VER
ARG FINDUTILS_VER
ARG GCC_14_BASE_VER
ARG GNU_WHICH_VER
ARG GZIP_VER
ARG LIBACL1_VER
ARG LIBATTR1_VER
ARG LIBC6_VER
ARG LIBCAP2_VER
ARG LIBGCC_S1_VER
ARG LIBGMP10_VER
ARG LIBPCRE2_8_0_VER
ARG LIBSELINUX1_VER
ARG LIBSYSTEMD0_VER
ARG LIBTINFO6_VER
ARG LIBZSTD1_VER
ARG NCURSES_BASE_VER
ARG NCURSES_BIN_VER
ARG NCURSES_TERM_VER
ARG TAR_VER
ARG TZDATA_VER
ARG ZLIB1G_VER

FROM ${BASE_IMAGE} AS rootfs-builder
USER root

ARG ACL_VER
ARG ATTR_VER
ARG BASE_FILES_VER
ARG BASH_VER
ARG CA_CERTIFICATES_VER
ARG COREUTILS_VER
ARG DEBCONF_VER
ARG DEBIANUTILS_VER
ARG FINDUTILS_VER
ARG GCC_14_BASE_VER
ARG GNU_WHICH_VER
ARG GZIP_VER
ARG LIBACL1_VER
ARG LIBATTR1_VER
ARG LIBC6_VER
ARG LIBCAP2_VER
ARG LIBGCC_S1_VER
ARG LIBGMP10_VER
ARG LIBPCRE2_8_0_VER
ARG LIBSELINUX1_VER
ARG LIBSYSTEMD0_VER
ARG LIBTINFO6_VER
ARG LIBZSTD1_VER
ARG NCURSES_BASE_VER
ARG NCURSES_BIN_VER
ARG NCURSES_TERM_VER
ARG TAR_VER
ARG TZDATA_VER
ARG ZLIB1G_VER

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y --no-install-recommends \
    debootstrap \
    ca-certificates

WORKDIR /
RUN debootstrap --variant=minbase trixie /rootfs http://deb.debian.org/debian/

RUN --mount=type=cache,target=/rootfs/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/rootfs/var/lib/apt/lists,sharing=locked \
    rm -f /rootfs/etc/apt/apt.conf.d/docker-clean && \
    chroot /rootfs apt-get update && chroot /rootfs apt-get install -y --allow-downgrades --no-install-recommends \
    acl=${ACL_VER} \
    attr=${ATTR_VER} \
    base-files=${BASE_FILES_VER} \
    bash=${BASH_VER} \
    ca-certificates=${CA_CERTIFICATES_VER} \
    coreutils=${COREUTILS_VER} \
    debconf=${DEBCONF_VER} \
    debianutils=${DEBIANUTILS_VER} \
    findutils=${FINDUTILS_VER} \
    gcc-14-base=${GCC_14_BASE_VER} \
    gnu-which=${GNU_WHICH_VER} \
    gzip=${GZIP_VER} \
    libacl1=${LIBACL1_VER} \
    libattr1=${LIBATTR1_VER} \
    libc6=${LIBC6_VER} \
    libcap2=${LIBCAP2_VER} \
    libgcc-s1=${LIBGCC_S1_VER} \
    libgmp10=${LIBGMP10_VER} \
    libpcre2-8-0=${LIBPCRE2_8_0_VER} \
    libselinux1=${LIBSELINUX1_VER} \
    libsystemd0=${LIBSYSTEMD0_VER} \
    libtinfo6=${LIBTINFO6_VER} \
    libzstd1=${LIBZSTD1_VER} \
    ncurses-base=${NCURSES_BASE_VER} \
    ncurses-bin=${NCURSES_BIN_VER} \
    ncurses-term=${NCURSES_TERM_VER} \
    tar=${TAR_VER} \
    tzdata=${TZDATA_VER} \
    zlib1g=${ZLIB1G_VER}

RUN --mount=type=cache,target=/rootfs/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/rootfs/var/lib/apt/lists,sharing=locked \
    chroot /rootfs apt-get update && chroot /rootfs apt-get dist-upgrade -y

RUN sed -i 's/umask 022/umask 027/g' /rootfs/etc/profile && \
    sed -i 's/umask 002/umask 027/g' /rootfs/etc/profile && \
    echo "umask 027" >> /rootfs/etc/bash.bashrc && \
    if [ -f /rootfs/etc/login.defs ]; then \
        sed -i 's/UMASK\s*022/UMASK 027/g' /rootfs/etc/login.defs; \
        sed -i 's/UMASK\s*002/UMASK 027/g' /rootfs/etc/login.defs; \
    fi

RUN mkdir -p /rootfs/root && \
    echo 'export PATH="/usr/sbin:/usr/bin:/sbin:/bin"' >> /rootfs/root/.bashrc && \
    echo 'export PATH="/usr/sbin:/usr/bin:/sbin:/bin"' >> /rootfs/root/.profile

RUN chroot /rootfs apt-get purge -y --auto-remove --allow-remove-essential \
    apt \
    libapt-pkg7.0

RUN rm -rf /rootfs/usr/bin/dpkg* \
           /rootfs/usr/sbin/dpkg* \
           /rootfs/var/lib/dpkg \
           /rootfs/etc/dpkg \
           /rootfs/usr/share/dpkg \
           /rootfs/var/log/dpkg.log

RUN rm -rf /rootfs/usr/share/doc/* \
           /rootfs/usr/share/man/* \
           /rootfs/usr/share/info/* \
           /rootfs/var/lib/apt/lists/* \
           /rootfs/var/cache/apt/* \
           /rootfs/var/log/*

FROM ${BASE_IMAGE} AS fips-builder
USER root
ARG FIPS_VERSION

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    perl \
    wget \
    ca-certificates

WORKDIR /src
RUN wget -q https://www.openssl.org/source/old/3.5/openssl-${FIPS_VERSION}.tar.gz || \
    wget -q https://www.openssl.org/source/openssl-${FIPS_VERSION}.tar.gz && \
    tar -xf openssl-${FIPS_VERSION}.tar.gz

WORKDIR /src/openssl-${FIPS_VERSION}
RUN ./Configure enable-fips && \
    make -j$(nproc)

FROM ${BASE_IMAGE} AS core-builder
USER root
ARG CORE_VERSION

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    perl \
    wget \
    ca-certificates

WORKDIR /src
RUN wget -q https://www.openssl.org/source/openssl-${CORE_VERSION}.tar.gz || \
    wget -q https://www.openssl.org/source/old/3.5/openssl-${CORE_VERSION}.tar.gz && \
    tar -xf openssl-${CORE_VERSION}.tar.gz

WORKDIR /src/openssl-${CORE_VERSION}
RUN ./Configure enable-fips shared --prefix=/usr --openssldir=/etc/ssl --libdir=lib && \
    make -j$(nproc) && \
    make install_sw install_ssldirs

FROM core-builder AS fips-integrator
USER root
ARG FIPS_VERSION

RUN ldconfig

COPY --from=fips-builder /src/openssl-${FIPS_VERSION}/providers/fips.so /usr/lib/ossl-modules/fips.so

RUN /usr/bin/openssl fipsinstall \
    -module /usr/lib/ossl-modules/fips.so \
    -out /etc/ssl/fipsmodule.cnf \
    -self_test_onload \
    -pedantic \
    -hmac_key_check \
    -kmac_key_check \
    -hkdf_digest_check \
    -hkdf_key_check \
    -kbkdf_key_check \
    -tls13_kdf_digest_check \
    -tls13_kdf_key_check \
    -tls1_prf_digest_check \
    -tls1_prf_key_check \
    -no_drbg_truncated_digests \
    -tdes_encrypt_disabled \
    -signature_digest_check \
    -rsa_pkcs15_padding_disabled \
    -rsa_pss_saltlen_check \
    -rsa_sign_x931_disabled \
    -dsa_sign_disabled \
    -ecdh_cofactor_check \
    -ems_check \
    -no_short_mac

RUN cat <<'EOF' > /etc/ssl/openssl.cnf
config_diagnostics = 1
openssl_conf = openssl_init

[openssl_init]
providers = provider_sect
alg_section = algorithm_sect

[algorithm_sect]
default_properties = fips=yes

[provider_sect]
fips = fips_sect
base = base_sect

[fips_sect]
.include /etc/ssl/fipsmodule.cnf
activate = 1

[base_sect]
activate = 1
EOF

RUN ln -sf libcrypto.so.3 /usr/lib/libcrypto.so && \
    ln -sf libssl.so.3 /usr/lib/libssl.so

FROM scratch AS runtime

COPY --from=rootfs-builder /rootfs /

COPY --from=fips-integrator /usr/bin/openssl /usr/bin/openssl
COPY --from=fips-integrator /usr/lib/libcrypto.so* /usr/lib/
COPY --from=fips-integrator /usr/lib/libssl.so* /usr/lib/
COPY --from=fips-integrator /usr/lib/ossl-modules /usr/lib/ossl-modules
COPY --from=fips-integrator /etc/ssl /etc/ssl

RUN groupadd -g 10001 sslgroup && \
    useradd -u 10001 -g sslgroup -m -s /bin/bash ssluser

ENV PATH="/usr/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:/lib" \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    OPENSSL_CONF=/etc/ssl/openssl.cnf \
    OPENSSL_MODULES=/usr/lib/ossl-modules

USER ssluser
WORKDIR /home/ssluser

HEALTHCHECK --interval=30s --timeout=3s --start-period=2s --retries=3 \
    CMD ["/usr/bin/openssl", "list", "-providers"]

ENTRYPOINT ["/bin/sh"]