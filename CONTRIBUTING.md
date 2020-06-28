# Coding Style

# Issues

# Pull Request

## Managing Submodule

If your changes require libdds changes to be include same then there is a few
extra steps to follow. You have to make sure required libdds changes have been
merged to http:://github.com/online-bridge-hackathon/libdds.

Merging commits to libdds doesn't automatically include merges to the library
used by service build process. The library version used by service is based on
commit attached to the submodule state. To update the commit you need to first
checkout the new commit into your submodule working tree. Then the change needs
to be staged and committed like source code changes. Following example shows
steps to update submodule to libdds master.

```
cd libdds
git checkout origin/master
cd ..
git add libdds
git commit
```

Submodule update can be included in a commit with service code changes for an
atomic update.
