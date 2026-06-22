import subprocess
import re
import sys

EXCLUDE = ["FIPS_VERSION", "CORE_VERSION"]

PKG_MAP = {
    "ACL_VER": "acl",
    "ATTR_VER": "attr",
    "BASE_FILES_VER": "base-files",
    "BASH_VER": "bash",
    "CA_CERTIFICATES_VER": "ca-certificates",
    "COREUTILS_VER": "coreutils",
    "DEBCONF_VER": "debconf",
    "DEBIANUTILS_VER": "debianutils",
    "FINDUTILS_VER": "findutils",
    "GCC_14_BASE_VER": "gcc-14-base",
    "GNU_WHICH_VER": "gnu-which",
    "GZIP_VER": "gzip",
    "LIBACL1_VER": "libacl1",
    "LIBATTR1_VER": "libattr1",
    "LIBC6_VER": "libc6",
    "LIBCAP2_VER": "libcap2",
    "LIBGCC_S1_VER": "libgcc-s1",
    "LIBGMP10_VER": "libgmp10",
    "LIBPCRE2_8_0_VER": "libpcre2-8-0",
    "LIBSELINUX1_VER": "libselinux1",
    "LIBSYSTEMD0_VER": "libsystemd0",
    "LIBTINFO6_VER": "libtinfo6",
    "LIBZSTD1_VER": "libzstd1",
    "NCURSES_BASE_VER": "ncurses-base",
    "NCURSES_BIN_VER": "ncurses-bin",
    "NCURSES_TERM_VER": "ncurses-term",
    "TAR_VER": "tar",
    "TZDATA_VER": "tzdata",
    "ZLIB1G_VER": "zlib1g"
}

def get_base_image_digest(image_tag):
    try:
        subprocess.run(["docker", "pull", image_tag], capture_output=True, check=True)
        res = subprocess.run(
            ["docker", "inspect", "--format={{index .RepoDigests 0}}", image_tag],
            capture_output=True, text=True, check=True
        )
        return res.stdout.strip()
    except Exception as e:
        print(f"Error pulling base image: {e}")
        return None

def get_debian_package_version(base_image, pkg_name):
    try:
        cmd = f"apt-get update >/dev/null && apt-cache policy {pkg_name}"
        res = subprocess.run(
            ["docker", "run", "--rm", base_image, "sh", "-c", cmd],
            capture_output=True, text=True, timeout=60, check=True
        )
        match = re.search(r"Candidate:\s*([^\s\n]+)", res.stdout)
        return match.group(1) if match else None
    except Exception as e:
        print(f"Error resolving version for package {pkg_name}: {e}")
        return None

def parse_existing_hcl(file_path):
    variables = {}
    if not re.search(r"versions\.hcl$", file_path):
        return variables
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        matches = re.findall(r'variable\s+"([^"]+)"\s+\{\s*default\s*=\s*"([^"]+)"\s*\}', content, re.MULTILINE)
        for key, val in matches:
            variables[key] = val
    except FileNotFoundError:
        pass
    return variables

def write_hcl(file_path, variables):
    lines = []
    
    lines.append(f'variable "BASE_IMAGE" {{')
    lines.append(f'  default = "{variables["BASE_IMAGE"]}"')
    lines.append("}\n")
    
    for key in sorted(variables.keys()):
        if key == "BASE_IMAGE":
            continue
        lines.append(f'variable "{key}" {{')
        lines.append(f'  default = "{variables[key]}"')
        lines.append("}\n")
        
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines).strip() + "\n")

def main():
    hcl_path = "versions.hcl"
    existing_vars = parse_existing_hcl(hcl_path)
    
    temp_base = "debian:trixie-slim"
    base_digest = get_base_image_digest(temp_base)
    if not base_digest:
        sys.exit(1)
        
    updated_vars = {}
    updated_vars["BASE_IMAGE"] = base_digest
    
    for exc_key in EXCLUDE:
        if exc_key in existing_vars:
            updated_vars[exc_key] = existing_vars[exc_key]
            
    for hcl_key, deb_name in PKG_MAP.items():
        if hcl_key in EXCLUDE:
            continue
        print(f"Fetching latest version for: {deb_name}")
        ver = get_debian_package_version(temp_base, deb_name)
        if ver:
            updated_vars[hcl_key] = ver
        else:
            if hcl_key in existing_vars:
                updated_vars[hcl_key] = existing_vars[hcl_key]
            else:
                print(f"Failed to find version for {deb_name}")
                sys.exit(1)
                
    write_hcl(hcl_path, updated_vars)
    print("versions.hcl successfully updated.")

if __name__ == "__main__":
    main()