Contributors are welcome! I'm a big believer in [the GitHub flow](http://guides.github.com/overviews/flow/). You can read about it there, but roughly, here's how I do it:

1. Fork the repo. :fork_and_knife:
2. Do your work on its own branch! Avoid working directly on `master`.
3. Open a pull request early, before you're finished. Prefix the title with "[wip]" to distinguish it from work that's ready to merge.
4. Push code! Comment on code! Collaborate!
5. Once it's ready to go, take the "[wip]" off the title. I'll merge it, then... profit!

Things to keep in mind while you're writing code:

1. Please add specs! I'm less strict about this for the notifiers and slurpers, but I try to keep the core well-specced. I'm using [minitest/spec](http://docs.seattlerb.org/minitest/#label-Specs) as a testing framework.
2. Use [YARD docs](http://rubydoc.info/gems/yard/file/docs/GettingStarted.md) on your methods where appropriate.
3. For code style, adhere to what's already there: 2-space indentation, parenthesis around method parameters, `{}` for single-line blocks and `do .. end` for multiline blocks.

## useful git commands

Here's a guide of the git commands you're most likely to need for this workflow:

```bash
# Clone your fork, and add this repository as the "upstream" remote.
git clone git@github.com:${GIT_USERNAME}/peril.git
git remote add --fetch upstream git@github.com:rackerlabs/peril.git

# Start a new branch for your work.
git checkout --no-track -b my-special-feature

# Make changes, stage them, and commit them.
git add -p
git commit -m "Extra descriptive message"

# Share your work early!
# The "-u" makes your local branch "track" the remote one.
# You'll only need it the first time; after that, "git push" will work nicely.
git push -u origin my-special-feature

# ... then open a pull request.

# Stay up to date with upstream work from time to time.
git pull upstream master

# Once it's merged, delete your branch from the pull request page, then you can clean up with:
git checkout master
git pull --prune upstream master
git push
```
