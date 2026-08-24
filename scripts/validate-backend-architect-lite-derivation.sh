#!/usr/bin/env bash
# Validates declared derivation mechanics only; it does not prove semantic equivalence or completeness.
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: validate-backend-architect-lite-derivation.sh [--check | --self-test] [--repo PATH] [--manifest PATH]

--check      Validate the canonical manifest and artifacts (default).
--self-test  Validate first, then prove the invariant-set guard rejects missing,
             duplicate, extra, and renamed invariant IDs using disposable /tmp data.
USAGE
}

mode="check"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"
manifest_path="$repo_root/derivation/backend-architect-lite-v3.1.2.json"

die() {
  printf 'derivation validation failed: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --check)
      mode="check"
      ;;
    --self-test)
      mode="self-test"
      ;;
    --repo)
      shift
      (($#)) || die "--repo requires a path"
      repo_root="$(cd -- "$1" && pwd -P)"
      ;;
    --manifest)
      shift
      (($#)) || die "--manifest requires a path"
      manifest_path="$1"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "unknown argument: $1"
      ;;
  esac
  shift
done

[[ -d "$repo_root" ]] || die "repository root is not a directory: $repo_root"
[[ -f "$manifest_path" ]] || die "manifest is not a file: $manifest_path"

temp_root="$(mktemp -d /tmp/backend-architect-derived-lite.XXXXXX)"
cleanup() {
  case "$temp_root" in
    /tmp/backend-architect-derived-lite.*)
      rm -rf -- "$temp_root"
      ;;
    *)
      printf 'derivation validation refused unsafe temporary cleanup path: %s\n' "$temp_root" >&2
      ;;
  esac
}
trap cleanup EXIT

python3 - "$repo_root" "$manifest_path" "$temp_root" <<'PY'
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
manifest_path = Path(sys.argv[2]).resolve()
temp_root = Path(sys.argv[3]).resolve()

EXPECTED_SOURCES = [
    "skills/backend-architect/SKILL.md",
    "skills/backend-architect/references/technical-reference.md",
    "skills/backend-architect/references/source-index.md",
]
EXPECTED_FORBIDDEN_INPUTS = [
    "skills/backend-architect-lite/SKILL.md",
    "versions/**/ARCHIVE.md",
    "versions/**/SKILL.md",
]
EXPECTED_INVARIANTS = sorted([
    ("activation-exclusions", "runtime-contract"),
    ("agent-trust-boundaries", "security-gate"),
    ("api-bff-protocol", "boundary-gate"),
    ("auth-security", "security-gate"),
    ("cache-compatibility", "operations-gate"),
    ("candidate-selection-conditionality", "decision-gate"),
    ("data-license-legal-residency", "governance-gate"),
    ("durable-workflows", "reliability-gate"),
    ("execution-order", "runtime-contract"),
    ("live-evidence-version-rules", "evidence-gate"),
    ("output-contract", "output-contract"),
    ("pglite-parity-limits", "data-gate"),
    ("pgvector-cve-remediation", "security-remediation"),
    ("privacy-observability", "operations-gate"),
    ("rejected-alternatives-risks-fallback", "output-contract"),
    ("runtime-portability", "runtime-gate"),
    ("source-discovery-stop-gate", "runtime-contract"),
    ("sqlite-edge-shortlist", "data-gate"),
    ("testing-production-parity", "validation-gate"),
])


def fail(message: str) -> None:
    raise SystemExit(f"derivation validation failed: {message}")


def read_repo_file(relative: str) -> bytes:
    if not isinstance(relative, str) or not relative:
        fail("manifest path must be a non-empty string")
    path = (repo / relative).resolve()
    if repo not in path.parents or not path.is_file():
        fail(f"required repository file is unavailable: {relative}")
    return path.read_bytes()


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require_version(relative: str) -> None:
    text = read_repo_file(relative).decode("utf-8")
    if not re.search(r'^  version: "3\.1\.2"$', text, re.MULTILINE):
        fail(f"v3.1.2 metadata is missing from {relative}")

try:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as error:
    fail(f"manifest cannot be parsed: {error}")

if not isinstance(manifest, dict):
    fail("manifest root must be an object")
if manifest.get("schemaVersion") != "1":
    fail("schemaVersion must be exactly '1'")
derivation = manifest.get("derivation")
if not isinstance(derivation, dict):
    fail("derivation must be an object")
if derivation.get("sourceVersion") != "3.1.2" or derivation.get("generatedVersion") != "3.1.2":
    fail("derivation source and generated versions must both be 3.1.2")
if "do not prove semantic" not in derivation.get("semanticProof", "").lower():
    fail("manifest must disclaim semantic proof")

sources = manifest.get("sourceFiles")
if not isinstance(sources, list) or [item.get("path") for item in sources if isinstance(item, dict)] != EXPECTED_SOURCES:
    fail("sourceFiles must be the exact ordered full runtime, technical reference, and source index")
if len(sources) != len(EXPECTED_SOURCES):
    fail("sourceFiles count is invalid")
for source in sources:
    if not isinstance(source, dict):
        fail("each sourceFiles entry must be an object")
    relative = source.get("path")
    declared_hash = source.get("sha256")
    if not isinstance(declared_hash, str) or not re.fullmatch(r"[0-9a-f]{64}", declared_hash):
        fail(f"source hash is invalid for {relative}")
    if relative.startswith("versions/") or relative == "skills/backend-architect-lite/SKILL.md":
        fail(f"forbidden prior-lite or archive input declared: {relative}")
    actual_hash = digest(read_repo_file(relative))
    if actual_hash != declared_hash:
        fail(f"source hash drift: {relative}")

if manifest.get("forbiddenInputs") != EXPECTED_FORBIDDEN_INPUTS:
    fail("forbiddenInputs must be the exact prior-lite and archive exclusions")

generated = manifest.get("generated")
if not isinstance(generated, dict):
    fail("generated must be an object")
if generated.get("path") != "skills/backend-architect-lite/SKILL.md":
    fail("generated.path must be the canonical lite skill")
if generated.get("archivePath") != "versions/v3.1.2-lite/ARCHIVE.md":
    fail("generated.archivePath must be the v3.1.2-lite archive")
if generated.get("version") != "3.1.2":
    fail("generated version must be 3.1.2")
generated_hash = generated.get("sha256")
if not isinstance(generated_hash, str) or not re.fullmatch(r"[0-9a-f]{64}", generated_hash):
    fail("generated hash is invalid")
lite_bytes = read_repo_file(generated["path"])
if digest(lite_bytes) != generated_hash:
    fail("generated lite hash drift")
if read_repo_file(generated["archivePath"]) != lite_bytes:
    fail("lite archive is not byte-identical to canonical lite")

expected_full_parity = [
    {"canonical": "skills/backend-architect/SKILL.md", "archive": "versions/v3.1.2/ARCHIVE.md"},
    {"canonical": "skills/backend-architect/references/technical-reference.md", "archive": "versions/v3.1.2/references/technical-reference.md"},
    {"canonical": "skills/backend-architect/references/source-index.md", "archive": "versions/v3.1.2/references/source-index.md"},
]
if manifest.get("fullArchiveParity") != expected_full_parity:
    fail("fullArchiveParity must declare the exact v3.1.2 full payload and references")
for pair in expected_full_parity:
    if read_repo_file(pair["canonical"]) != read_repo_file(pair["archive"]):
        fail(f"full archive parity failed: {pair['canonical']}")

for relative in [
    "skills/backend-architect/SKILL.md",
    "skills/backend-architect-lite/SKILL.md",
    "versions/v3.1.2/ARCHIVE.md",
    "versions/v3.1.2-lite/ARCHIVE.md",
]:
    require_version(relative)

invariants = manifest.get("invariants")
if not isinstance(invariants, list):
    fail("invariants must be an array")
actual_invariants = []
for invariant in invariants:
    if not isinstance(invariant, dict):
        fail("each invariant must be an object")
    invariant_id = invariant.get("id")
    category = invariant.get("category")
    if not isinstance(invariant_id, str) or not isinstance(category, str):
        fail("each invariant requires string id and category")
    actual_invariants.append((invariant_id, category))
if len(actual_invariants) != len(EXPECTED_INVARIANTS) or sorted(actual_invariants) != EXPECTED_INVARIANTS:
    fail("invariant ID/category set or count differs from the exact expected set")
if len({identifier for identifier, _ in actual_invariants}) != len(actual_invariants):
    fail("duplicate invariant ID")
source_text = {relative: read_repo_file(relative).decode("utf-8") for relative in EXPECTED_SOURCES}
lite_text = lite_bytes.decode("utf-8")
for invariant in invariants:
    source_path = invariant.get("sourcePath")
    source_anchor = invariant.get("sourceAnchor")
    lite_anchor = invariant.get("liteAnchor")
    if source_path not in source_text:
        fail(f"invariant {invariant['id']} has a non-source input path")
    if not isinstance(source_anchor, str) or not source_anchor:
        fail(f"invariant {invariant['id']} has no source anchor")
    if not isinstance(lite_anchor, str) or not lite_anchor:
        fail(f"invariant {invariant['id']} has no lite anchor")
    if source_anchor not in source_text[source_path]:
        fail(f"source anchor drift for invariant {invariant['id']}")
    if lite_anchor not in lite_text:
        fail(f"lite anchor drift for invariant {invariant['id']}")

omissions = manifest.get("omissions")
if not isinstance(omissions, list) or len(omissions) < 3:
    fail("omissions must describe the compacted rationale, tables, and links")
for omission in omissions:
    if not isinstance(omission, dict) or not isinstance(omission.get("category"), str) or not isinstance(omission.get("reason"), str):
        fail("each omission requires category and reason")

archive_skill_files = list((repo / "versions").rglob("SKILL.md"))
if archive_skill_files:
    fail("archive SKILL.md files are discoverable: " + ", ".join(str(path.relative_to(repo)) for path in archive_skill_files))
expected_discovery = sorted([
    Path("skills/backend-architect-lite/SKILL.md"),
    Path("skills/backend-architect/SKILL.md"),
])
normal_discovery = sorted(path.relative_to(repo / "skills") for path in (repo / "skills").rglob("SKILL.md"))
if normal_discovery != sorted(path.relative_to("skills") for path in expected_discovery):
    fail("normal discovery must expose exactly the canonical full and lite skills")
full_depth_discovery = sorted(
    path.relative_to(repo)
    for path in repo.rglob("SKILL.md")
    if ".git" not in path.relative_to(repo).parts and ".codegraph" not in path.relative_to(repo).parts
)
if full_depth_discovery != expected_discovery:
    fail("full-depth discovery must expose exactly the canonical full and lite skills")

install_root = temp_root / "clean-install"
shutil.copytree(repo / "skills" / "backend-architect", install_root / "backend-architect")
install_lite = install_root / "backend-architect-lite" / "SKILL.md"
install_lite.parent.mkdir(parents=True)
shutil.copy2(repo / "skills" / "backend-architect-lite" / "SKILL.md", install_lite)
if (install_root / "versions").exists():
    fail("clean install copied an archive")
for relative in expected_discovery:
    source = repo / relative
    installed = install_root / relative.relative_to("skills")
    if not installed.is_file() or source.read_bytes() != installed.read_bytes():
        fail(f"clean install byte mismatch: {relative}")
require_install_version = re.compile(r'^  version: "3\.1\.2"$', re.MULTILINE)
for installed in [install_root / "backend-architect" / "SKILL.md", install_root / "backend-architect-lite" / "SKILL.md"]:
    if not require_install_version.search(installed.read_text(encoding="utf-8")):
        fail(f"clean install lacks v3.1.2 metadata: {installed.name}")
for reference in ["technical-reference.md", "source-index.md"]:
    if not (install_root / "backend-architect" / "references" / reference).is_file():
        fail(f"clean full install lacks local reference: {reference}")

print("derivation validation passed: hashes, invariant anchors, archive parity, discovery, and clean-install bytes")
PY

if [[ "$mode" == "self-test" ]]; then
  for case_name in missing duplicate extra renamed; do
    case_manifest="$temp_root/$case_name.json"
    python3 - "$manifest_path" "$case_manifest" "$case_name" <<'PY'
import json
import sys

source, destination, case_name = sys.argv[1:]
with open(source, encoding="utf-8") as handle:
    manifest = json.load(handle)
invariants = manifest["invariants"]
if case_name == "missing":
    invariants.pop()
elif case_name == "duplicate":
    invariants.append(dict(invariants[0]))
elif case_name == "extra":
    invariants.append({"id": "unexpected-invariant", "category": "test"})
elif case_name == "renamed":
    invariants[0]["id"] = "activation-exclusions-renamed"
else:
    raise SystemExit(f"unknown self-test case: {case_name}")
with open(destination, "w", encoding="utf-8") as handle:
    json.dump(manifest, handle, indent=2)
    handle.write("\n")
PY
    if bash "$script_dir/validate-backend-architect-lite-derivation.sh" --check --repo "$repo_root" --manifest "$case_manifest" >/dev/null 2>&1; then
      die "self-test unexpectedly accepted $case_name invariant IDs"
    fi
    printf 'self-test rejected %s invariant IDs\n' "$case_name"
  done
fi
