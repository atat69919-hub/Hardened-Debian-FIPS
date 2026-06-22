variable "REGISTRY" {
  default = "ghcr.io"
}

variable "OWNER" {
  default = "atat69919-hub"
}

variable "REPO_NAME" {
  default = "debian-13-fips"
}

group "default" {
  targets = ["debian-fips"]
}

target "debian-fips" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  cache-from = ["type=gha,scope=trixie-fips"]
  cache-to   = ["type=gha,scope=trixie-fips,mode=max"]
  tags       = [
    "${REGISTRY}/${OWNER}/${REPO_NAME}:latest",
    "${REGISTRY}/${OWNER}/${REPO_NAME}:${CORE_VERSION}"
  ]
  args = {
    BASE_IMAGE          = "${BASE_IMAGE}"
    FIPS_VERSION        = "${FIPS_VERSION}"
    CORE_VERSION        = "${CORE_VERSION}"
    ACL_VER             = "${ACL_VER}"
    ATTR_VER            = "${ATTR_VER}"
    BASE_FILES_VER      = "${BASE_FILES_VER}"
    BASH_VER            = "${BASH_VER}"
    CA_CERTIFICATES_VER = "${CA_CERTIFICATES_VER}"
    COREUTILS_VER       = "${COREUTILS_VER}"
    DEBCONF_VER         = "${DEBCONF_VER}"
    DEBIANUTILS_VER     = "${DEBIANUTILS_VER}"
    FINDUTILS_VER       = "${FINDUTILS_VER}"
    GCC_14_BASE_VER     = "${GCC_14_BASE_VER}"
    GNU_WHICH_VER       = "${GNU_WHICH_VER}"
    GZIP_VER            = "${GZIP_VER}"
    LIBACL1_VER         = "${LIBACL1_VER}"
    LIBATTR1_VER         = "${LIBATTR1_VER}"
    LIBC6_VER           = "${LIBC6_VER}"
    LIBCAP2_VER         = "${LIBCAP2_VER}"
    LIBGCC_S1_VER       = "${LIBGCC_S1_VER}"
    LIBGMP10_VER        = "${LIBGMP10_VER}"
    LIBPCRE2_8_0_VER    = "${LIBPCRE2_8_0_VER}"
    LIBSELINUX1_VER     = "${LIBSELINUX1_VER}"
    LIBSYSTEMD0_VER     = "${LIBSYSTEMD0_VER}"
    LIBTINFO6_VER       = "${LIBTINFO6_VER}"
    LIBZSTD1_VER        = "${LIBZSTD1_VER}"
    NCURSES_BASE_VER    = "${NCURSES_BASE_VER}"
    NCURSES_BIN_VER     = "${NCURSES_BIN_VER}"
    NCURSES_TERM_VER    = "${NCURSES_TERM_VER}"
    TAR_VER             = "${TAR_VER}"
    TZDATA_VER          = "${TZDATA_VER}"
    ZLIB1G_VER          = "${ZLIB1G_VER}"
  }
}