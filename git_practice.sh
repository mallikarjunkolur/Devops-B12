# Creating an interactive Git practice bash script and saving it to /mnt/data/git_practice_lab.sh
script = r'''#!/usr/bin/env bash
# git_practice_lab.sh
# Interactive Git Hands-On Lab (one repo with multiple labs)
# Usage: bash git_practice_lab.sh
# Created: automated by ChatGPT
set -euo pipefail

TOPDIR="$PWD/git_practice_lab"
REMOTE_DIR="/mnt/data/git_practice_remote.git"

pause() {
  echo
  read -rp ">>> Press Enter when you have completed the step (or to continue) ..."
  echo
}

heading() {
  echo
  echo "============================================"
  echo "  $1"
  echo "============================================"
  echo
}

safe_cmd() {
  echo "+ $*"
  eval "$@"
}

echo "This script will create an interactive Git practice repo at:"
echo "  $TOPDIR"
echo "and a local bare remote at:"
echo "  $REMOTE_DIR"
echo
read -rp "Continue and create these (existing content may be overwritten)? (y/N) " CONF
if [[ "${CONF,,}" != "y" ]]; then
  echo "Aborted by user."
  exit 1
fi

# Clean previous runs (if any)
rm -rf "$TOPDIR" "$REMOTE_DIR"

# Create remote bare repo to simulate GitHub
safe_cmd "mkdir -p \"$REMOTE_DIR\""
safe_cmd "git init --bare \"$REMOTE_DIR\" >/dev/null 2>&1"

# Create main working repo
safe_cmd "mkdir -p \"$TOPDIR\""
cd "$TOPDIR"
safe_cmd "git init . >/dev/null 2>&1"

# Set local config to avoid git complaining
safe_cmd "git config user.name 'Practice User'"
safe_cmd "git config user.email 'practice@example.com'"

heading "LAB SETUP: create initial commits on main"
echo "Creating initial commits on main..."
cat > README.md <<'EOF'
Git Practice Lab
Follow on-screen instructions for each lab.
EOF
safe_cmd "git add README.md"
safe_cmd "git commit -m 'chore: add README' >/dev/null 2>&1"
# create some baseline files and commits
echo "lineA" > fileA.txt
safe_cmd "git add fileA.txt && git commit -m 'feat: add fileA' >/dev/null 2>&1"
echo "lineB" > fileB.txt
safe_cmd "git add fileB.txt && git commit -m 'feat: add fileB' >/dev/null 2>&1"

# add remote and push main
safe_cmd "git remote add origin \"$REMOTE_DIR\""
safe_cmd "git branch -M main"
safe_cmd "git push -u origin main >/dev/null 2>&1"

echo "Repo created. Path: $TOPDIR"
echo "Remote (bare) created: $REMOTE_DIR"

heading "LAB 1 — Branching & Basic Workflow (feature branch)"
echo "Scenario: create a feature branch, make commits, and push to origin."
echo "Actions for you (open a NEW terminal in this repo):"
echo "  cd \"$TOPDIR\""
echo "  git switch -c feature/login"
echo "  echo 'login page' >> fileA.txt"
echo "  git commit -am 'feat: add login page'"
echo "  echo 'validation' >> fileA.txt"
echo "  git commit -am 'fix: add validation'"
echo "  git push -u origin feature/login"
echo
pause

heading "LAB 2 — Merge & Resolve Conflict (manual)"
echo "I will create a conflicting change on main for you to merge."
# Make a conflicting change on main and push to remote (simulate someone else)
safe_cmd "git switch main >/dev/null 2>&1"
echo "main-change" > conflict.txt
safe_cmd "git add conflict.txt && git commit -m 'chore: main adds conflict file' >/dev/null 2>&1"
safe_cmd "git push origin main >/dev/null 2>&1"

echo "Now: switch to feature branch and try merging main to reproduce conflict."
echo "Actions (in your working terminal):"
echo "  cd \"$TOPDIR\""
echo "  git switch feature/login"
echo "  # open conflict.txt and edit the same lines as main (or simply run)"
echo "  echo 'feature change' > conflict.txt"
echo "  git commit -am 'feat: feature modifies conflict file'"
echo "  git merge main || true"
echo "Resolve the conflict by editing conflict.txt, then run:"
echo "  git add conflict.txt"
echo "  git commit -m 'fix: resolved merge conflict'"
pause

heading "LAB 3 — Rebase vs Merge (interactive practice)"
echo "We will create branch dev and show difference between merge and rebase."
safe_cmd "git switch main >/dev/null 2>&1"
safe_cmd "git switch -c dev"
echo "devline1" >> dev.txt
safe_cmd "git add dev.txt && git commit -m 'dev: add devline1' >/dev/null 2>&1"
safe_cmd "git switch main >/dev/null 2>&1"
echo "mainline1" >> main.txt
safe_cmd "git add main.txt && git commit -m 'main: add mainline1' >/dev/null 2>&1"

echo "Now try two approaches in YOUR terminal:"
echo "A) Merge main into dev:  git switch dev; git merge main"
echo "B) Reset dev to previous state (if needed) then rebase dev onto main:"
echo "   # to reset dev back to before merge (if you merged):"
echo "   git switch dev; git reset --hard origin/dev || true"
echo "   # to rebase dev onto main:"
echo "   git switch dev; git rebase main"
echo
pause

heading "LAB 4 — Interactive Rebase & Squash"
echo "We create a messy branch 'mess' with multiple small commits to squash."
safe_cmd "git switch main >/dev/null 2>&1"
safe_cmd "git switch -c mess"
echo "line1" >> messy.txt; safe_cmd "git add messy.txt && git commit -m 'mess: line1' >/dev/null 2>&1"
echo "line2" >> messy.txt; safe_cmd "git add messy.txt && git commit -m 'mess: line2' >/dev/null 2>&1"
echo "typo fix" >> messy.txt; safe_cmd "git add messy.txt && git commit -m 'mess: fix typo' >/dev/null 2>&1"

echo "Now run (in your terminal):"
echo "  git log --oneline"
echo "  git rebase -i HEAD~3"
echo "Change 'pick' to 'squash' for the last two commits to combine them into the first."
pause

heading "LAB 5 — Stash, Apply, and Stash Branch"
echo "Create a working change and stash it, then create a branch from stash."
safe_cmd "git switch main >/dev/null 2>&1"
echo "temporary work" >> stash.txt
safe_cmd "git add stash.txt >/dev/null 2>&1 || true"
echo "Now, in your terminal run:"
echo "  cd \"$TOPDIR\""
echo "  git stash push -m 'WIP: practicing stash'"
echo "  git stash list"
echo "  git stash branch stash-branch stash@{0}"
echo "Inspect the new branch 'stash-branch'."
pause

heading "LAB 6 — Revert, Reset, and Recover with Reflog"
echo "We will create a commit you can revert and also show reset modes."
safe_cmd "git switch main >/dev/null 2>&1"
echo "temp-commit" > temp.txt
safe_cmd "git add temp.txt && git commit -m 'temp: add temp file' >/dev/null 2>&1"
echo "Commands to try in your terminal:"
echo "  git log --oneline -n 5"
echo "  # revert the temp commit (creates a new commit):"
echo "  git revert HEAD"
echo "  # undo the revert if desired (revert the revert):"
echo "  git revert HEAD"
echo "  # or experiment with reset (careful):"
echo "  git reset --soft HEAD~1  # undo commit, keep staged"
echo "  git reset --mixed HEAD~1 # undo commit, keep working changes"
echo "  git reset --hard HEAD~1  # WARNING: deletes working changes"
echo "You can recover lost commits using 'git reflog' to find SHA then 'git switch -c recover <sha>'"
pause

heading "LAB 7 — Cherry-pick & Hotfix"
safe_cmd "git switch main >/dev/null 2>&1"
safe_cmd "git switch -c hotfix"
echo "hotfix change" > hotfix.txt; safe_cmd "git add hotfix.txt && git commit -m 'hotfix: add hotfix' >/dev/null 2>&1"
safe_cmd "git switch main >/dev/null 2>&1"
echo "Now practice cherry-pick in your terminal:"
echo "  git switch main"
echo "  git cherry-pick $(git rev-parse --short hotfix) || true"
pause

heading "LAB 8 — Tags & Releases"
echo "Create annotated tag and push it."
safe_cmd "git switch main >/dev/null 2>&1"
safe_cmd "git tag -a v0.1 -m 'v0.1 release' >/dev/null 2>&1 || true"
safe_cmd "git push origin --tags >/dev/null 2>&1 || true"
echo "Now list tags in your terminal: git tag -l"
pause

heading "LAB 9 — Clean, Ignored Files, and .gitignore"
echo "Create ignored files and practice git clean."
safe_cmd "git switch main >/dev/null 2>&1"
echo "node_modules/" > .gitignore
echo "debug.log" >> .gitignore
safe_cmd "git add .gitignore && git commit -m 'chore: add gitignore' >/dev/null 2>&1"
# create untracked files
mkdir -p node_modules/sample && touch debug.log temp.tmp node_modules/sample/a.js
echo "Run these commands in your terminal to practice cleaning:"
echo "  git status --ignored"
echo "  git clean -n -d   # preview"
echo "  git clean -f -d   # delete untracked dirs"
echo "  git clean -fX -d  # delete ignored files too (dangerous)"
pause

heading "LAB 10 — Remote Collaboration & Force Push Simulation"
echo "This simulates non-fast-forward and force push recovery."
safe_cmd "git switch main >/dev/null 2>&1"
safe_cmd "git switch -c collab"
echo "collab change" > collab.txt; safe_cmd "git add collab.txt && git commit -m 'collab: change' >/dev/null 2>&1"
safe_cmd "git push -u origin collab >/dev/null 2>&1 || true"
echo "Now, in a separate clone simulate remote change:"
# create a clone to simulate another dev
CLONE_DIR="/tmp/git_practice_clone"
rm -rf "$CLONE_DIR"
safe_cmd "git clone \"$REMOTE_DIR\" \"$CLONE_DIR\" >/dev/null 2>&1"
safe_cmd "cd \"$CLONE_DIR\" && git switch -c collab && echo 'other dev edit' > other.txt && git add other.txt && git commit -m 'other: remote edit' >/dev/null 2>&1 && git push origin collab >/dev/null 2>&1 || true"
safe_cmd "cd \"$TOPDIR\""
echo "Now if you try to push your local collab branch, you'll get a non-fast-forward error."
echo "Practice resolving it in your terminal using:"
echo "  git pull --rebase origin collab"
echo "  # or inspect and force push if appropriate:"
echo "  git push --force-with-lease origin collab"
pause

heading "LAB 11 — Bisect (find bad commit)"
safe_cmd "git switch main >/dev/null 2>&1"
# create a sequence of commits, with one 'bad' introduced
safe_cmd "git switch -c bisect-lab >/dev/null 2>&1 || true"
echo "good" > bisect.txt; safe_cmd "git add bisect.txt && git commit -m 'bisect: good1' >/dev/null 2>&1"
echo "good" >> bisect.txt; safe_cmd "git add bisect.txt && git commit -m 'bisect: good2' >/dev/null 2>&1"
echo "BAD" >> bisect.txt; safe_cmd "git add bisect.txt && git commit -m 'bisect: bad commit' >/dev/null 2>&1"
echo "good" >> bisect.txt; safe_cmd "git add bisect.txt && git commit -m 'bisect: good3' >/dev/null 2>&1"
echo "Now in your terminal run:"
echo "  git bisect start"
echo "  git bisect bad"
echo "  git bisect good HEAD~3"
echo "Follow prompts to find the bad commit, then git bisect reset"
pause

heading "FINISHED: Summary & Tips"
echo "All labs created under: $TOPDIR"
echo "A bare remote was created at: $REMOTE_DIR (acts like origin)"
echo
echo "Recommended workflow to practice:"
echo " - Open TWO terminals: one for running commands here, one for executing the Git exercises."
echo " - Use 'git log --oneline --graph --all' often to inspect history."
echo " - Use 'git reflog' when you think you lost commits."
echo
echo "When you're done, you can delete the practice repo with:"
echo "  rm -rf \"$TOPDIR\" \"$REMOTE_DIR\" /tmp/git_practice_clone"
echo
echo "Enjoy practicing!"
'''

with open('/mnt/data/git_practice_lab.sh', 'w') as f:
    f.write(script)

import os
os.chmod('/mnt/data/git_practice_lab.sh', 0o755)

print("Created /mnt/data/git_practice_lab.sh")

