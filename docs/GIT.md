# How to make changes to the this repository in Git

As the repository is infrastructure as code, shared by different projects and environments
it's important to have a standard way to make changes in the repository.

This is important for the following reasons:

* When something breaks we want to quickly identify the root problem which caused it.
* Small changes can be done directly on main branch, it's important to keep main branch always able to fast forward changes.

## Commit messages

When making commits, either manually or via the GitHub web UI, please use the following format:

`environment-names: description of changes (optionally - issue number)`

It's recommended not to have too many changes in one commit, but if you do separate environment names / description with commas:

`environment1,environment2: description one, description two (ISSUE1, ISSUE2)`

## Pull before making changes and before pushing changes

Before making changes be sure to pull latest changes from main branch (`git pull origin main`)

Make sure to do the same before pushing changes as well, remember that some changes in this repository occur automatically
from continuous deployment of other repositories.

If you forgot to pull and attempted to push to main branch while other changes happened, no big deal,
just continue with an additional merge commit (default behavior of the git client). Don't do a rebase or any other tricks
as it may cause problems for other users working on the code base.

## Merging pull requests

When merging pull requests (or if you want to merge manually), 
please don't merge a lot of different commits as this pollutes the commit log with a lot of unnecesarry details.

Using the GitHub UI, change the merge button to do a squash commit:

![image](https://user-images.githubusercontent.com/1198854/121542972-3ce7a180-ca11-11eb-8f16-7cfbe6a6a75d.png)

It will create a single commit with all the changes, you can then edit the commit message according to the above format.
