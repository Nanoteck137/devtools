import subprocess


def run_cmd(cmd, stdout=False):
    out = None
    if stdout:
        out = subprocess.PIPE

    return subprocess.run(cmd, check=True, stdout=out, encoding="utf-8")


def get_diff_files() -> [str]:
    res = run_cmd(["git", "diff", "--name-only"], stdout=True)
    if res.stdout == "":
        return []
    return res.stdout.strip().split("\n")


def get_staged_files() -> [str]:
    res = run_cmd(["git", "diff", "--staged", "--name-only"], stdout=True)
    if res.stdout == "":
        return []
    return res.stdout.strip().split("\n")


modified_files = get_diff_files()
print(modified_files)
if len(modified_files) > 0:
    print("Commit or Stash modified files")
    exit(-1)

staged_files = get_staged_files()
print(staged_files)
if len(staged_files) > 0:
    print("Commit staged files")
    exit(-1)

version = ""
with open("version") as f:
    version = f.read().strip()

print("Current Version:", version)

new_version = input("New Version: ").strip()
print(new_version)

tag_name = "v{}".format(new_version)

res = run_cmd(["git", "tag", "-l", tag_name], stdout=True)
if res.stdout.strip() != "":
    print("Version already exists")
    exit(-1)

with open("version", "w") as f:
    f.write("{}\n".format(new_version))

run_cmd(["git", "add", "version"])

staged_files = get_staged_files()
if len(staged_files) != 1 or staged_files[0] != "version":
    print("Incorrect setup")
    exit(-1)

run_cmd(["git", "commit", "-m", "Version {}".format(new_version)])
run_cmd(["git", "push"])

run_cmd(["git", "tag", tag_name])
run_cmd(["git", "push", "origin", tag_name])
