#!/usr/bin/env python3

import argparse
import shlex
import shutil
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser("deploy-tag")
    parser.add_argument("docker_tag")
    parser.add_argument("--description", default=None)
    opts = parser.parse_args()

    try:
        deployment_group = {
            "staging": "dev",
            "main": "prod",
        }[opts.docker_tag]
    except KeyError:
        print(f"No deployment group for {opts.docker_tag}")
        return 0

    description = opts.description if opts.description else f"Deploy {opts.docker_tag}"

    # write the environment file
    with open("deploy/tag.env", "w") as fh:
        fh.write(f"WELLINGTON_DOCKER_TAG={opts.docker_tag}\n")

    cli = shutil.which("aws")
    command = [
        cli,
        "deploy",
        "push",
        "--application-name",
        "Wellington",
        "--s3-location",
        f"s3://deploy.chicon.org/wellington/{opts.docker_tag}.zip",
        "--source",
        ".",
        "--description",
        description,
    ]

    res = subprocess.run(command, cwd="./deploy", capture_output=True)
    res.check_returncode()

    lines = [_.decode("utf-8") for _ in res.stdout.splitlines()]
    deploy_command_line = [_ for _ in lines if "aws deploy create-deployment" in _][0]
    command_parts = shlex.split(deploy_command_line)

    def keep(parts):
        skip_next = False
        for part in parts:
            if skip_next:
                skip_next = False
                continue

            if part in (
                "--deployment-group-name",
                "--deployment-config-name",
                "--description",
            ):
                skip_next = True
                continue

            yield part

    command = list(keep(command_parts))
    command += ["--description", description]
    command += ["--deployment-group-name", deployment_group]

    subprocess.run(command).check_returncode()


if __name__ == "__main__":
    main()
