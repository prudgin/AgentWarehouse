#!/usr/bin/env bash
# check-docs.sh — mechanical doc-sweep helper for /finish.
#
# Modes:
#   --orphans       For each directory referenced in CLAUDE.md's "Documentation map"
#                   section, verify every *.md file in that directory is mentioned
#                   in the directory's README.md (substring match).
#   --broken-links  Scan all *.md files under the project root for relative markdown
#                   links and verify each target file (and anchor, if present) exists.
#   --all           Run both. Exit 1 if either reports findings.
#
# Exit 0 if no issues, 1 otherwise. Findings on stdout, warnings on stderr.
#
# Heuristics:
#   - Fenced code blocks (``` or ~~~) are skipped: nothing inside them is a link.
#   - Inline code spans (backticks within a line) are stripped before link extraction.
#   - HTML comments (<!-- ... -->) are skipped (single- and multi-line).
#   - Directories that contain external reference material or pre-instantiation
#     templates are excluded entirely from the broken-link sweep:
#         references/, templates/, target-projects/
#     These hold placeholder content (e.g. <module>.md) that is not meant to
#     resolve in-place.

set -u

# Discover project root from this script's location: skills/finish/scripts/check-docs.sh
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../../.." && pwd)"

mode="${1:-}"
if [[ -z "$mode" ]]; then
    echo "usage: $0 --orphans | --broken-links | --all" >&2
    exit 2
fi

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------

# Build a list of directories referenced by CLAUDE.md's Documentation map section.
# A directory reference is any markdown link target that ends with '/' or that
# points at '<dir>/README.md'. Output is newline-separated, relative to project_root.
extract_doc_map_dirs() {
    local claude_md="$project_root/CLAUDE.md"
    if [[ ! -f "$claude_md" ]]; then
        echo "warning: $claude_md not found; skipping orphan sweep" >&2
        return 1
    fi

    # Extract the section between '## Documentation map' and the next '## ' heading.
    local section
    section="$(awk '
        /^## Documentation map[[:space:]]*$/ { in_section = 1; next }
        in_section && /^## / { in_section = 0 }
        in_section { print }
    ' "$claude_md")"

    if [[ -z "$section" ]]; then
        echo "warning: '## Documentation map' section not found in CLAUDE.md; skipping orphan sweep" >&2
        return 1
    fi

    printf '%s\n' "$section" \
        | grep -oE '\]\([^)]+\)' \
        | sed -E 's/^\]\(//; s/\)$//' \
        | while IFS= read -r target; do
            target="${target%%#*}"
            [[ -z "$target" ]] && continue
            [[ "$target" =~ ^https?:// ]] && continue
            if [[ "$target" == */ ]]; then
                printf '%s\n' "${target%/}"
            elif [[ "$target" == */README.md ]]; then
                printf '%s\n' "${target%/README.md}"
            fi
        done \
        | sort -u
}

# GitHub-style heading slug: lowercase, non-alphanumerics → '-', collapse runs,
# trim leading/trailing '-'.
slugify() {
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# Print all heading slugs in a markdown file (one per line). Skips fenced code.
extract_heading_slugs() {
    local f="$1"
    [[ -f "$f" ]] || return 0
    awk '
        /^[[:space:]]*```/ { fence = !fence; next }
        /^[[:space:]]*~~~/ { fence = !fence; next }
        !fence && /^#{1,6} / { print }
    ' "$f" \
        | sed -E 's/^#{1,6} +//; s/[[:space:]]+$//' \
        | while IFS= read -r heading; do
            slugify "$heading"
        done
}

# List all *.md files in scope, excluding hidden tooling dirs and pre-instantiation
# / external dirs that contain placeholder content.
list_md_files() {
    find "$project_root" \
        -type d \( \
            -name .git -o -name node_modules -o -name .venv -o -name .next \
            -o -name dist -o -name build \
            -o -path "$project_root/references" \
            -o -path "$project_root/templates" \
            -o -path "$project_root/target-projects" \
        \) -prune \
        -o -type f -name '*.md' -print
}

# ----------------------------------------------------------------------------
# Orphans
# ----------------------------------------------------------------------------

run_orphans() {
    local orphans=0
    local dirs
    if ! dirs="$(extract_doc_map_dirs)"; then
        echo "WARN: orphan sweep skipped" >&2
        return 0
    fi

    while IFS= read -r reldir; do
        [[ -z "$reldir" ]] && continue
        local absdir="$project_root/$reldir"
        if [[ ! -d "$absdir" ]]; then
            echo "warning: doc map references '$reldir/' but directory does not exist" >&2
            continue
        fi
        local readme="$absdir/README.md"
        if [[ ! -f "$readme" ]]; then
            echo "warning: '$reldir/' has no README.md (cannot check orphans inside it)" >&2
            continue
        fi
        local readme_content
        readme_content="$(cat "$readme")"
        while IFS= read -r mdfile; do
            [[ -z "$mdfile" ]] && continue
            local base
            base="$(basename "$mdfile")"
            [[ "$base" == "README.md" ]] && continue
            if [[ "$readme_content" != *"$base"* ]]; then
                printf '%s\n' "$reldir/$base"
                orphans=$((orphans + 1))
            fi
        done < <(find "$absdir" -maxdepth 1 -type f -name '*.md' | sort)
    done <<< "$dirs"

    if [[ "$orphans" -eq 0 ]]; then
        echo "OK: no orphans"
        return 0
    else
        echo "FAIL: $orphans orphan(s)"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Broken links
# ----------------------------------------------------------------------------

# Strip inline code spans (single-backtick `...`) and HTML inline comments from a
# line, so links in `[x](y)` form embedded in literal-code don't get flagged.
strip_code_and_comments() {
    # Use sed to:
    #   - remove `...` spans (non-greedy, single line)
    #   - remove <!-- ... --> spans on a single line
    sed -E 's/`[^`]*`//g; s/<!--[^>]*-->//g'
}

run_broken_links() {
    local broken=0
    local source_file
    while IFS= read -r source_file; do
        [[ -z "$source_file" ]] && continue
        local source_dir
        source_dir="$(dirname "$source_file")"
        local lineno=0
        local in_fence=0
        local in_html_comment=0
        while IFS= read -r raw_line; do
            lineno=$((lineno + 1))
            # Track fenced code blocks. A fence starts with ``` or ~~~ at start of
            # line (allowing leading spaces). Toggle on each.
            if [[ "$raw_line" =~ ^[[:space:]]*\`\`\` ]] || [[ "$raw_line" =~ ^[[:space:]]*~~~ ]]; then
                in_fence=$((1 - in_fence))
                continue
            fi
            [[ "$in_fence" -eq 1 ]] && continue
            # Track multi-line HTML comments.
            if [[ "$in_html_comment" -eq 1 ]]; then
                if [[ "$raw_line" == *"-->"* ]]; then
                    in_html_comment=0
                fi
                continue
            fi
            if [[ "$raw_line" == *"<!--"* && "$raw_line" != *"-->"* ]]; then
                in_html_comment=1
                continue
            fi
            # Strip inline code spans and inline HTML comments.
            local line
            line="$(printf '%s\n' "$raw_line" | strip_code_and_comments)"
            local matches
            matches="$(printf '%s\n' "$line" | grep -oE '\[[^]]*\]\([^)]+\)' || true)"
            [[ -z "$matches" ]] && continue
            while IFS= read -r match; do
                [[ -z "$match" ]] && continue
                local target="${match##*\(}"
                target="${target%\)}"
                [[ "$target" =~ ^https?:// ]] && continue
                [[ "$target" =~ ^mailto: ]] && continue
                [[ "$target" =~ ^# ]] && continue
                local path_part="${target%%#*}"
                local anchor=""
                if [[ "$target" == *"#"* ]]; then
                    anchor="${target#*#}"
                fi
                [[ -z "$path_part" ]] && continue
                local resolved
                if [[ "$path_part" == /* ]]; then
                    resolved="$project_root$path_part"
                else
                    resolved="$source_dir/$path_part"
                fi
                resolved="$(readlink -m "$resolved")"
                if [[ ! -e "$resolved" ]]; then
                    local rel="${source_file#$project_root/}"
                    printf '%s:%d:%s\n' "$rel" "$lineno" "$target"
                    broken=$((broken + 1))
                    continue
                fi
                if [[ -n "$anchor" && "$resolved" == *.md ]]; then
                    local found=0
                    while IFS= read -r slug; do
                        if [[ "$slug" == "$anchor" ]]; then
                            found=1
                            break
                        fi
                    done < <(extract_heading_slugs "$resolved")
                    if [[ "$found" -eq 0 ]]; then
                        local rel="${source_file#$project_root/}"
                        printf '%s:%d:%s\n' "$rel" "$lineno" "$target"
                        broken=$((broken + 1))
                    fi
                fi
            done <<< "$matches"
        done < "$source_file"
    done < <(list_md_files | sort)

    if [[ "$broken" -eq 0 ]]; then
        echo "OK: no broken links"
        return 0
    else
        echo "FAIL: $broken broken link(s)"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Dispatch
# ----------------------------------------------------------------------------

case "$mode" in
    --orphans)
        run_orphans
        exit $?
        ;;
    --broken-links)
        run_broken_links
        exit $?
        ;;
    --all)
        rc=0
        run_orphans || rc=1
        run_broken_links || rc=1
        exit $rc
        ;;
    *)
        echo "usage: $0 --orphans | --broken-links | --all" >&2
        exit 2
        ;;
esac
