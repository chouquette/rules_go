# Copyright 2025 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""windres_toolchain rule for registering a Windows resource compiler.

A windres toolchain is optional. When registered, rules_go uses it to embed a
longPathAware PE manifest into every go_test binary targeting Windows. This
allows the test binary to use file paths longer than MAX_PATH (260 characters)
when LongPathsEnabled=1 is set in the Windows registry.

Example – registering the MinGW windres for AMD64 Windows cross-compilation:

    load("@io_bazel_rules_go//go/private:windres.bzl", "windres_toolchain")

    windres_toolchain(
        name = "windres_mingw_amd64",
        tool = "@mingw_toolchain//:windres",
    )

    toolchain(
        name = "windres_mingw_amd64_toolchain",
        exec_compatible_with = [
            "@platforms//os:linux",
        ],
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":windres_mingw_amd64",
        toolchain_type = "@io_bazel_rules_go//go:windres_toolchain",
    )

Then in WORKSPACE or MODULE.bazel:

    register_toolchains("//:windres_mingw_amd64_toolchain")
"""

WindresInfo = provider(
    doc = "Information about a windres resource compiler.",
    fields = {
        "tool": "A FilesToRunProvider for the windres executable.",
    },
)

def _windres_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            windres_info = WindresInfo(
                tool = ctx.attr.tool[DefaultInfo].files_to_run,
            ),
        ),
    ]

windres_toolchain = rule(
    implementation = _windres_toolchain_impl,
    attrs = {
        "tool": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            doc = "The windres executable (built for the exec/host platform).",
        ),
    },
    doc = """Declares a windres resource compiler for use with rules_go.

Wrap a windres binary with this rule and register it as a toolchain of type
@io_bazel_rules_go//go:windres_toolchain. Use target_compatible_with on the
toolchain() wrapper to restrict which (os, cpu) target platforms it applies to.
""",
)
