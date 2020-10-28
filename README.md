This is an experiment. The code is structured as follows:

- fetch.sh: contains the code to fetch commits until there is a
  common ancestor between two branches, and only those commits
  necessary to reach this common ancestor.

- test.sh: contains the test runner and sources the tests found
  in the tests/ folder. You can run it like so:

  - `./test.sh`: runs all the tests until the first one that fails.
  - `./test.sh <N>`: runs only test number <N>.
  - `./test.sh --all`: runs all tests regardless of whether one fails.

Current status:

- There are 2 failing tests: when one branch is ancestor of the other
  with 1 commit of difference and the remote HEAD points to the oldest
  branch.

- When fetching diverged branches, the current script fails to obtain
  commits until a common ancestor is reached. This is currently not
  considered a bug given that the purpose of the script, for now, is
  to act only when one branch is ancestor of the other, and fail with
  an error when branches diverge.
