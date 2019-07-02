"""Rules making pulling github packages easier.

Since majority of our dependencies are on github, it makes sense to make pulling
github tar.gz easier.
"""

load("@io_bazel_rules_go//go:def.bzl", "go_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _github_tar_gz_url(package, commit, tag):
    if commit:
        return "https://github.com/" + package + "/archive/" + commit + ".tar.gz"
    else:
        return "https://github.com/" + package + "/archive/" + tag + ".tar.gz"

def _tar_gz_prefix(package, commit, tag):
    basename = package.split("/")[-1]
    if commit:
        return basename + "-" + commit
    else:
        # Github omits the first "v" when produce .tar.gz files if the tags begin
        # with "v". E.g., the prefix to strip for package of version v1.0.2 is
        # "package-1.0.2", yet for version "release-1.8.0" is
        # "package-release-1.8.0".
        if tag.startswith("v"):
            return basename + "-" + tag[1:]
        return basename + "-" + tag

def github_http_archive(name, package, commit = None, tag = None, sha256 = ""):
    """Adding bazel repository from github.

    Args:
      name: (string) Target name, should be com_github_{fullpath}. This should be
        case sensitive, e.g., com_github_Shopify_sarama.
      package: (string) Package name without "github.com/", E.g.,
        github.com/Shopify/sarama has package name Shopify/sarama. No trailing
        slash is allowed.
      commit: (string) Commit number.
      tag: (string) Commit tag. Exactly one of commit or tag is required.
      sha256: (string) Optional checksum.
    """
    return http_archive(
        name = name,
        urls = [_github_tar_gz_url(package, commit, tag)],
        strip_prefix = _tar_gz_prefix(package, commit, tag),
        sha256 = sha256,
    )

def github_new_http_archive(name, package, build_file = None, build_file_content = None, commit = None, tag = None, sha256 = ""):
    """Adding bazel repository from github.

    Args:
      name: (string) Target name, should be com_github_{fullpath}. This should be
        case sensitive, e.g., com_github_Shopify_sarama.
      package: (string) Package name without "github.com/", E.g.,
        github.com/Shopify/sarama has package name Shopify/sarama. No trailing
        slash is allowed.
      build_file: (string) Build file path.
      build_file_content: (string) Build file content.
      commit: (string) Commit number.
      tag: (string) Commit tag. Exactly one of commit or tag is required.
      sha256: (string) Optional checksum.
    """
    return http_archive(
        name = name,
        urls = [_github_tar_gz_url(package, commit, tag)],
        strip_prefix = _tar_gz_prefix(package, commit, tag),
        sha256 = sha256,
        build_file = build_file,
        build_file_content = build_file_content,
    )

def github_go_repository(name, package, importpath = "", commit, tag, sha256 = "", mirror_urls = [], **kwargs):
    """Adding go repository from github and convert it to bazel repository.

    Note that for now the dependencies will not be pulled in automatically. You
    need to build and run wtools
    (https://github.com/bazelbuild/rules_go/tree/master/go/tools/wtool)
    to add all the dependencies.

    Args:
      name: (string) Target name, should be com_github_{fullpath}. This should be
        case sensitive, e.g., com_github_Shopify_sarama.
      package: (string) Package name without "github.com/", E.g.,
        github.com/Shopify/sarama has package name Shopify/sarama. No trailing
        slash is allowed. The Go import path is
        github.com/Shopify/sarama.
      commit: (string) Commit number.
      tag: (string) Commit tag. Exactly one of commit or tag is required.
      mirror_urls: (list of string) Optional list of mirror URLs. This does not
        have to include the github URL.
    """
    if importpath == "":
        importpath = "github.com/" + package
    return go_repository(
        name = name,
        importpath = importpath,
        urls = [_github_tar_gz_url(package, commit, tag)] + mirror_urls,
        strip_prefix = _tar_gz_prefix(package, commit, tag),
        sha256 = sha256,
        **kwargs
    )
