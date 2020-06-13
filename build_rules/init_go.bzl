load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def init_go():
    # NOTE(yi.sun): This is not the newest version of rules_go. However, we
    # have to stuck with this version as later version removes support for
    # go_prefix, which requires us to rework ALL the repositories.
    http_archive(
        name = "io_bazel_rules_go",
        url = "https://github.com/iminders/rules_go/archive/04b95865433488427992ffd0274e971973ff364f.tar.gz",
        strip_prefix = "rules_go-04b95865433488427992ffd0274e971973ff364f",
    )
